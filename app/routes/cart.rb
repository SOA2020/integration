# frozen_string_literal: true

CART_ROUTE = proc do
  get '/commodity' do
    token = request.env['HTTP_TOKEN'].to_s
    uid = params['userId']
    page = params['pageNumber']
    Auth.auth!(uid, token)

    url = URI("#{CART_SERVICE}/commodity?userId=#{uid}&pageNumber=#{page}")
    begin
      resp = Faraday.get(url)
    rescue StandardError => e
      puts e.message.to_s
    end

    if resp.status == 401
      raise UnauthorizedError, 'UnauthorizedError'
    elsif resp.status == 404
      raise NotFoundError.new('Cart', 'NotFound')
    elsif resp.status >= 400
      raise BadRequestError, 'BadRequest'
    end

    cart = JSON.parse(resp.body)
    cart['commodities'].each do |comm|
      comm_id = comm['commodityId']
      comm_url = URI("#{INVENTORY_SERVICE}/commodity/#{comm_id}")

      begin
        comm_resp = Faraday.get(comm_url)
      rescue StandardError => e
        puts e.message.to_s
      end

      if comm_resp.status == 401
        raise UnauthorizedError, 'UnauthorizedError'
      elsif comm_resp.status == 404
        raise NotFoundError.new('Commodity', 'NotFound')
      elsif comm_resp.status >= 400
        raise BadRequestError, 'BadRequest'
      end

      commodity = JSON.parse(comm_resp.body)
      comm['commodityName'] = commodity['commodityName'].to_s
      comm['commodityPrice'] = commodity['commodityPrice'].to_i
      comm['commodityColor'] = commodity['commodityColor'].to_s
      comm['commodityImage'] = commodity['commodityImage'].to_s
      comm['commoditySpecification'] = commodity['commoditySpecification'].to_s
      comm['commodityInventory'] = commodity['commodityInventory'].to_i
      comm['commodityType'] = commodity['commodityType'].to_i
    end
    yajl :cart, locals: { count: cart['count'],
                          page: cart['pgNum'],
                          size: cart['pgSize'],
                          commodities: cart['commodities'] }
  end

  post '/commodity' do
    req = JSON.parse(request.body.read)
    token = request.env['HTTP_TOKEN'].to_s
    uid = req['userId']
    Auth.auth!(uid, token)

    json = {userId: req['userId'], commodityId: req['commodityId'], num: req['num']}.to_json
    url = URI("#{CART_SERVICE}/commodity")
    begin
      resp = Faraday.post(url, json, {'Content-Type' => 'application/json'})
    rescue StandardError => e
      puts e.message.to_s
    end

    if resp.status == 401
      raise UnauthorizedError, 'UnauthorizedError'
    elsif resp.status == 404
      raise NotFoundError.new('Cart', 'NotFound')
    elsif resp.status >= 400
      raise BadRequestError, 'BadRequest'
    end

    comm = JSON.parse(resp.body)
    comm_id = comm['commodityId']
    comm_url = URI("#{INVENTORY_SERVICE}/commodity/#{comm_id}")
    begin
      comm_resp = Faraday.get(comm_url)
    rescue StandardError => e
      puts e.message.to_s
    end

    if comm_resp.status == 401
      raise UnauthorizedError, 'UnauthorizedError'
    elsif comm_resp.status == 404
      raise NotFoundError.new('Commodity', 'NotFound')
    elsif comm_resp.status >= 400
      raise BadRequestError, 'BadRequest'
    end

    commodity = JSON.parse(comm_resp.body)
    comm['commodityName'] = commodity['commodityName'].to_s
    comm['commodityPrice'] = commodity['commodityPirce'].to_i
    comm['commodityColor'] = commodity['commodityColor'].to_s
    comm['commodityImage'] = commodity['commodityImage'].to_s
    comm['commoditySpecification'] = commodity['commoditySpecification'].to_s
    comm['commodityInventory'] = commodity['commodityInventory'].to_i
    comm['commodityType'] = commodity['commodityType'].to_i

    yajl :cart_comm, locals: {comm: comm}
  end

  delete '/commodity' do
    token = request.env['HTTP_TOKEN'].to_s
    uid = params['userId']
    comm_id = params['commodityId']
    Auth.auth!(uid, token)

    url = URI("#{CART_SERVICE}/commodity?userId=#{uid}&commodityId=#{comm_id}")
    begin
      resp = Faraday.delete(url)
    rescue StandardError => e
      puts e.message.to_s
    end

    if resp.status == 401
      raise UnauthorizedError, 'UnauthorizedError'
    elsif resp.status == 404
      raise NotFoundError.new('Cart', 'NotFound')
    elsif resp.status >= 400
      raise BadRequestError, 'BadRequest'
    end

    resp.body
  end

  put '/commodity' do
    req = JSON.parse(request.body.read)
    token = request.env['HTTP_TOKEN'].to_s
    uid = params['userId']
    comm_id = params['commodityId']
    Auth.auth!(uid, token)

    json = { num: req['num']}.to_json
    url = URI("#{CART_SERVICE}/commodity?userId=#{uid}&commodityId=#{comm_id}")
    begin
      resp = Faraday.put(url, json, {'Content-Type' => 'application/json'})
    rescue StandardError => e
      puts e.message.to_s
    end

    if resp.status == 401
      raise UnauthorizedError, 'UnauthorizedError'
    elsif resp.status == 404
      raise NotFoundError.new('Cart', 'NotFound')
    elsif resp.status >= 400
      raise BadRequestError, 'BadRequest'
    end

    comm = JSON.parse(resp.body)
    comm_id = comm['commodityId']
    comm_url = URI("#{INVENTORY_SERVICE}/commodity/#{comm_id}")
    begin
      comm_resp = Faraday.get(comm_url)
    rescue StandardError => e
      puts e.message.to_s
    end

    if comm_resp.status == 401
      raise UnauthorizedError, 'UnauthorizedError'
    elsif comm_resp.status == 404
      raise NotFoundError.new('Commodity', 'NotFound')
    elsif comm_resp.status >= 400
      raise BadRequestError, 'BadRequest'
    end

    commodity = JSON.parse(comm_resp.body)
    comm['commodityName'] = commodity['commodityName'].to_s
    comm['commodityPrice'] = commodity['commodityPirce'].to_i
    comm['commodityColor'] = commodity['commodityColor'].to_s
    comm['commodityImage'] = commodity['commodityImage'].to_s
    comm['commoditySpecification'] = commodity['commoditySpecification'].to_s
    comm['commodityInventory'] = commodity['commodityInventory'].to_i
    comm['commodityType'] = commodity['commodityType'].to_i

    yajl :cart_comm, locals: {comm: comm}
  end
end
