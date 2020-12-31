# frozen_string_literal: true

PAYMENT_ROUTE = proc do
  post '/purchase' do
    # TODO: Purchase some goods
  end

  get '/tokenCoin' do
    token = request.env['HTTP_TOKEN'].to_s
    uid = params['userId']
    Auth.auth!(uid, token)
    url = URI("#{PAYMENT_SERVICE}/tokencoin?userId=#{uid}")

    begin
      resp = Faraday.get(url)
    rescue StandardError => e
      puts e.message.to_s
    end

    if resp.status == 401
      raise UnauthorizedError, 'UnauthorizedError'
    elsif resp.status == 404
      raise NotFoundError.new('Token Coin', 'NotFound')
    elsif resp.status >= 400
      raise BadRequestError, 'BadRequest'
    end

    resp.body
  end

  put '/tokenCoin' do
    req = JSON.parse(request.body.read)
    token = request.env['HTTP_TOKEN'].to_s
    uid = req['userId']
    Auth.admin!(uid, token)

    json = { userId: req['userId'], tokenCoin: req['tokenCoin'] }.to_json
    url = URI("#{PAYMENT_SERVICE}/tokencoin")

    begin
      resp = Faraday.put(url, json)
    rescue StandardError => e
      puts e.message.to_s
    end

    if resp.status == 401
      raise UnauthorizedError, 'UnauthorizedError'
    elsif resp.status == 404
      raise NotFoundError.new('Token Coin', 'NotFound')
    elsif resp.status >= 400
      raise BadRequestError, 'BadRequest'
    end

    resp.body
  end
end
