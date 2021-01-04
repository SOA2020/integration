# frozen_string_literal: true

PAYMENT_ROUTE = proc do
  post '/purchase' do
    req = JSON.parse(request.body.read)

    # Auth
    uid = req['userId']
    token = request.env['HTTP_TOKEN'].to_s
    Auth.auth!(uid, token)

    total_price = 0
    req['commodities'].each do |comm|
      # Check inventory
      requested = comm['count'].to_i
      comm_id = comm['commodityId'].to_i
      inventory_url = URI("#{INVENTORY_SERVICE}/commodity/#{comm_id}")

      begin
        inventory_resp = Faraday.get(inventory_url)
      rescue StandardError => e
        puts e.message.to_s
      end

      if inventory_resp.status == 401
        raise UnauthorizedError, 'UnauthorizedError'
      elsif inventory_resp.status == 404
        raise NotFoundError.new('Inventory', 'NotFound')
      elsif inventory_resp.status >= 400
        raise BadRequestError, 'BadRequest'
      end

      commodity = JSON.parse(inventory_resp.body)
      in_stock = commodity['commodityInventory'].to_i
      # Out of stock
      raise BadRequestError, 'BadRequest' unless in_stock >= requested

      price = commodity['commodityPrice'].to_i
      total_price += (requested * price)
    end

    # Try to Purchase
    purchase_url = URI("#{PAYMENT_SERVICE}/purchase")
    purchase_json = {userId: uid.to_s, price: total_price.to_i, count: 1}.to_json
    begin
      purchase_resp = Faraday.post(purchase_url, purchase_json)
    rescue StandardError => e
      puts e.message.to_s
    end

    if purchase_resp.status == 401
      raise UnauthorizedError, 'UnauthorizedError'
    elsif purchase_resp.status == 404
      raise NotFoundError.new('Token Coin', 'NotFound')
    elsif purchase_resp.status >= 400
      raise BadRequestError, 'BadRequest'
    end


    # Update inventory
    req['commodities'].each do |comm|
      requested = comm['count'].to_i
      comm_id = comm['commodityId'].to_i
      update_comm_url = URI("#{INVENTORY_SERVICE}/commodity/#{comm_id}/number?num=#{-requested}")

      begin
        update_comm_resp = Faraday.put(update_comm_url)
      rescue StandardError => e
        puts e.message.to_s
      end

      if update_comm_resp.status >= 400
        # Last resort
        puts update_comm_resp.body
        raise BadRequestError, 'BadRequest'
      end
    end

    # Generate an order
    order_url = URI("#{ORDER_SERVICE}/order")
    order_json = {userId: uid, commodity: req['commodities'], deliveryId: req['deliveryId']}.to_json
    begin
      order_resp = Faraday.post(order_url, order_json, {'Content-Type' => 'application/json'})
    rescue StandardError => e
      puts e.message.to_s
    end
    if order_resp.status == 401
      raise UnauthorizedError, 'UnauthorizedError'
    elsif order_resp.status == 404
      raise NotFoundError.new('Token Coin', 'NotFound')
    elsif order_resp.status >= 400
      raise BadRequestError, 'BadRequest'
    end

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
    uid = req['adminId']
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
