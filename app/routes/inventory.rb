# frozen_string_literal: true

INVENTORY_ROUTE = proc do
  get '/commodity' do
    page_number = (params['pageNumber'] || 1).to_i
    if params['type'].nil?
      url = URI("#{INVENTORY_SERVICE}/commodity?pageNumber=#{page_number}")
    else
      type = params['type'].to_i
      url = URI("#{INVENTORY_SERVICE}/commodity?pageNumber=#{page_number}&type=#{type}")
    end

    begin
      resp = Faraday.get(url)
    rescue StandardError => e
      puts e.message.to_s
    end

    if resp.status == 401
      raise UnauthorizedError, 'UnauthorizedError'
    elsif resp.status == 404
      raise NotFoundError.new('Commodity', 'NotFound')
    elsif resp.status >= 400
      raise BadRequestError, 'BadRequest'
    end

    resp.body
  end

  post '/commodity' do
    req = JSON.parse(request.body.read)
    token = request.env['HTTP_TOKEN'].to_s
    uid = req['userId']
    Auth.admin!(uid, token)

    url = URI("#{INVENTORY_SERVICE}/commodity")

    json = { commodityName: req['commodityName'].to_s,
             commodityPrice: req['commodityPrice'].to_i,
             commodityColor: req['commodityColor'].to_s,
             commodityImage: req['commodityImage'].to_s,
             commoditySpecification: req['commoditySpecification'].to_s,
             commodityInventory: req['commodityInventory'].to_i,
             commodityType: req['commodityType'].to_i,
             introduction: req['introduction'].to_s }.to_json
    # Not my code.to_json

    begin
      resp = Faraday.post(url, json, {'Content-Type' => 'application/json'})
    rescue StandardError => e
      puts e.message.to_s
    end

    if resp.status == 401
      raise UnauthorizedError, 'UnauthorizedError'
    elsif resp.status == 404
      raise NotFoundError.new('Inventory', 'NotFound')
    elsif resp.status >= 400
      raise BadRequestError, 'BadRequest'
    end

    resp.body
  end

  get '/commodity/:id' do |id|
    url = URI("#{INVENTORY_SERVICE}/commodity/#{id}")

    begin
      resp = Faraday.get(url)
    rescue StandardError => e
      puts e.message.to_s
    end

    if resp.status == 401
      raise UnauthorizedError, 'UnauthorizedError'
    elsif resp.status == 404
      raise NotFoundError.new('Commodity', 'NotFound')
    elsif resp.status >= 400
      raise BadRequestError, 'BadRequest'
    end

    resp.body
  end

  delete '/commodity/:id' do |id|
    token = request.env['HTTP_TOKEN'].to_s
    uid = params['userId']
    Auth.admin!(uid, token)

    url = URI("#{INVENTORY_SERVICE}/commodity/#{id}")

    begin
      resp = Faraday.delete(url)
    rescue StandardError => e
      puts e.message.to_s
    end

    if resp.status == 401
      raise UnauthorizedError, 'UnauthorizedError'
    elsif resp.status == 404
      raise NotFoundError.new('Inventory', 'NotFound')
    elsif resp.status >= 400
      raise BadRequestError, 'BadRequest'
    end

    resp.body
  end

  put '/commodity/:id' do |id|
    req = JSON.parse(request.body.read)
    token = request.env['HTTP_TOKEN'].to_s
    uid = req['userId']
    Auth.admin!(uid, token)

    url = URI("#{INVENTORY_SERVICE}/commodity/#{id}")

    json = { commodityName: req['commodityName'].to_s,
             commodityPrice: req['commodityPrice'].to_i,
             commodityColor: req['commodityColor'].to_s,
             commodityImage: req['commodityImage'].to_s,
             commoditySpecification: req['commoditySpecification'].to_s,
             commodityInventory: req['commodityInventory'].to_i,
             commodityType: req['commodityType'].to_i,
             introduction: req['introduction'].to_s}
    # Not my code.to_json

    begin
      resp = Faraday.put(url, json, {'Content-Type' => 'application/json'})
    rescue StandardError => e
      puts e.message.to_s
    end

    if resp.status == 401
      raise UnauthorizedError, 'UnauthorizedError'
    elsif resp.status == 404
      raise NotFoundError.new('Inventory', 'NotFound')
    elsif resp.status >= 400
      raise BadRequestError, 'BadRequest'
    end

    resp.body
  end

  post '/commodity/search' do
    # TODO: FIXME
  end
end
