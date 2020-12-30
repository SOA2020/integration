# frozen_string_literal: true

USER_ROUTE = proc do
  post '/register' do
    req = JSON.parse(request.body.read)
    url = URI("#{USER_SERVICE}/register")
    json = { email: (req['email']).to_s,
             nickname: (req['nickname']).to_s,
             password: (req['password']).to_s }.to_json
    begin
      resp = Faraday.post(url, json)
    rescue StandardError => e
      puts e.message
    end

    if resp.status == 404
      raise NotFoundError, 'NotFound'
    elsif resp.status > 400
      raise BadRequestError, 'BadRequest'
    end

    resp.body
  end

  post '/login' do
    req = JSON.parse(request.body.read)
    url = URI("#{USER_SERVICE}/login")
    json = { email: (req['email']).to_s,
             password: (req['password']).to_s }.to_json
    begin
     resp = Faraday.post(url, json)
    rescue StandardError => e
      puts e.message
   end

    if resp.status == 404
      raise NotFoundError, 'NotFound'
    elsif resp.status > 400
      raise BadRequestError, 'BadRequest'
    end

    resp.body
  end

  get '/:id' do |id|
    req = JSON.parse(request.body.read)
    token = request.env['HTTP_TOKEN'].to_s
    url = URI("#{USER_SERVICE}/user/#{id}")

    begin
      resp = Faraday.get(url, nil ,{'token' => token})
     rescue StandardError => e
       puts e.message
    end

    if resp.status == 401
      raise UnauthorizedError, 'UnauthorizedError'
    elsif resp.status == 404
      raise NotFoundError, 'NotFound'
    elsif resp.status > 400
      raise BadRequestError, 'BadRequest'
    end

    resp.body
  end
end
