# frozen_string_literal: true

USER_ROUTE = proc do
  post '/register' do
    req = JSON.parse(request.body.read)
    register_url = URI("#{USER_SERVICE}/register")
    register_json = { email: (req['email']).to_s,
                      nickname: (req['nickname']).to_s,
                      password: (req['password']).to_s }.to_json

    # Post to user subsystem to register
    begin
      register_resp = Faraday.post(register_url, register_json)
    rescue StandardError => e
      puts e.message.to_s
    end

    if register_resp.status == 404
      raise NotFoundError.new('Registery', 'NotFound')
    elsif register_resp.status > 400
      raise BadRequestError, 'BadRequest'
    end

    # Post to payment subsystem to get some token coins for a new user
    ## Fetch user id
    begin
      profile = JSON.parse(register_resp.body)
    rescue StandardError => e
      puts e.message.to_s
    end
    uid = profile['id'].to_s

    token_coin_url = URI("#{PAYMENT_SERVICE}/tokencoin")
    token_coin_json = { userId: uid, tokenCoin: '5000' }.to_json
    begin
      token_coin_resp = Faraday.post(token_coin_url, token_coin_json)
    rescue StandardError => e
      puts e.message.to_s
    end

    if token_coin_resp.status == 404
      raise NotFoundError.new('Token Coin', 'NotFound')
    elsif token_coin_resp.status > 400
      raise BadRequestError, 'BadRequest'
    end

    register_resp.body
  end

  post '/login' do
    req = JSON.parse(request.body.read)
    url = URI("#{USER_SERVICE}/login")
    json = { email: (req['email']).to_s,
             password: (req['password']).to_s }.to_json
    begin
     resp = Faraday.post(url, json)
    rescue StandardError => e
      puts e.message.to_s
   end

    if resp.status == 404
      raise NotFoundError.new('User', 'NotFound')
    elsif resp.status > 400
      raise BadRequestError, 'BadRequest'
    end

    resp.body
  end

  get '/:id' do |id|
    token = request.env['HTTP_TOKEN'].to_s
    url = URI("#{USER_SERVICE}/user/#{id}")

    begin
      resp = Faraday.get(url, nil, { 'token' => token })
    rescue StandardError => e
      puts e.message.to_s
    end

    if resp.status == 401
      raise UnauthorizedError, 'UnauthorizedError'
    elsif resp.status == 404
      raise NotFoundError.new('Profile', 'NotFound')
    elsif resp.status > 400
      raise BadRequestError, 'BadRequest'
    end

    resp.body
  end

  get '' do
    token = request.env['HTTP_TOKEN'].to_s
    page = (params[:page] || 1).to_i
    size = (params[:size] || 10).to_i
    url = URI("#{USER_SERVICE}/user?page=#{page}&size=#{size}")

    begin
      resp = Faraday.get(url, nil, { 'token' => token })
    rescue StandardError => e
      puts e.message.to_s
    end

    if resp.status == 401
      raise UnauthorizedError, 'UnauthorizedError'
    elsif resp.status == 404
      raise NotFoundError.new('Profiles', 'NotFound')
    elsif resp.status > 400
      raise BadRequestError, 'BadRequest'
    end

    resp.body
  end

  put '/:id' do |id|
    req = JSON.parse(request.body.read)
    token = request.env['HTTP_TOKEN'].to_s
    url = URI("#{USER_SERVICE}/user/#{id}")

    hash = {}
    hash['nickname'] = req['nickname'].to_s unless req['nickname'].nil?
    hash['email'] = req['email'].to_s unless req['email'].nil?
    hash['avatar'] = req['avatar'].to_s unless req['avatar'].nil?
    json = hash.to_json

    begin
      resp = Faraday.put(url, json, { 'token' => token})
    rescue StandardError => e
      puts e.message.to_s
    end

    if resp.status == 401
      raise UnauthorizedError, 'UnauthorizedError'
    elsif resp.status == 404
      raise NotFoundError.new('Profile', 'NotFound')
    elsif resp.status > 400
      raise BadRequestError, 'BadRequest'
    end

    resp.body
  end

  put '/:id/password' do |id|
    req = JSON.parse(request.body.read)
    token = request.env['HTTP_TOKEN'].to_s
    url = URI("#{USER_SERVICE}/user/#{id}/password")

    json = {password: (req['password']).to_s}.to_json

    begin
      resp = Faraday.put(url, json, { 'token' => token})
    rescue StandardError => e
      puts e.message.to_s
    end

    if resp.status == 401
      raise UnauthorizedError, 'UnauthorizedError'
    elsif resp.status == 404
      raise NotFoundError.new('Profile', 'NotFound')
    elsif resp.status > 400
      raise BadRequestError, 'BadRequest'
    end

    resp.body
  end

  post '/:id/delivery_infos' do |id|
    req = JSON.parse(request.body.read)
    token = request.env['HTTP_TOKEN'].to_s
    url = URI("#{USER_SERVICE}/user/#{id}/delivery_infos")

    json = {name: (req['name']).to_s,
            phone: (req['phone']).to_s,
            address: (req['address']).to_s}.to_json

    begin
      resp = Faraday.post(url, json, { 'token' => token})
    rescue StandardError => e
      puts e.message.to_s
    end

    if resp.status == 401
      raise UnauthorizedError, 'UnauthorizedError'
    elsif resp.status == 404
      raise NotFoundError.new('Delivery Infos', 'NotFound')
    elsif resp.status > 400
      raise BadRequestError, 'BadRequest'
    end

    resp.body
  end

  put '/:id/delivery_infos/:info_id' do |id, info_id|
    req = JSON.parse(request.body.read)
    token = request.env['HTTP_TOKEN'].to_s
    url = URI("#{USER_SERVICE}/user/#{id}/delivery_infos/#{info_id}")

    hash = {}
    hash['name'] = req['name'].to_s unless req['name'].nil?
    hash['phone'] = req['phone'].to_s unless req['phone'].nil?
    hash['address'] = req['address'].to_s unless req['address'].nil?
    json = hash.to_json

    begin
      resp = Faraday.put(url, json, { 'token' => token})
    rescue StandardError => e
      puts e.message.to_s
    end

    if resp.status == 401
      raise UnauthorizedError, 'UnauthorizedError'
    elsif resp.status == 404
      raise NotFoundError.new('Delivery Info', 'NotFound')
    elsif resp.status > 400
      raise BadRequestError, 'BadRequest'
    end

    resp.body
  end

  get '/:id/delivery_infos' do |id|
    token = request.env['HTTP_TOKEN'].to_s
    page = (params[:page] || 1).to_i
    size = (params[:size] || 10).to_i
    url = URI("#{USER_SERVICE}/user/#{id}/delivery_infos?page=#{page}&size=#{size}")

    begin
      resp = Faraday.get(url, nil, { 'token' => token})
    rescue StandardError => e
      puts e.message.to_s
    end

    if resp.status == 401
      raise UnauthorizedError, 'UnauthorizedError'
    elsif resp.status == 404
      raise NotFoundError.new('Delivery Infos', 'NotFound')
    elsif resp.status > 400
      raise BadRequestError, 'BadRequest'
    end

    resp.body
  end

  delete '/:id/delivery_infos/:info_id' do |id, info_id|
    token = request.env['HTTP_TOKEN'].to_s
    url = URI("#{USER_SERVICE}/user/#{id}/delivery_infos/#{info_id}")

    begin
      resp = Faraday.delete(url, nil, { 'token' => token})
    rescue StandardError => e
      puts e.message.to_s
    end

    if resp.status == 401
      raise UnauthorizedError, 'UnauthorizedError'
    elsif resp.status == 404
      raise NotFoundError.new('Delivery Info', 'NotFound')
    elsif resp.status > 400
      raise BadRequestError, 'BadRequest'
    end

    resp.body
  end
end
