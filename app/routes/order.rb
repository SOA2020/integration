# frozen_string_literal: true

ORDER_ROUTE = proc do
  get '' do
    page = params['pageNumber']
    uid = params['userId']
    token = request.env['HTTP_TOKEN'].to_s
    user = Auth.auth!(uid, token)

    send_status = params['sendStatus']
    order_url = URI("#{ORDER_SERVICE}/order?userId=#{uid}&pageNumber=#{page}&sendStatus=#{send_status}")

    begin
      order_resp = Faraday.get(order_url)
    rescue StandardError => e
      puts e.message.to_s
    end

    if order_resp.status == 401
      raise UnauthorizedError, 'UnauthorizedError'
    elsif order_resp.status == 404
      raise NotFoundError.new('Order', 'NotFound')
    elsif order_resp.status >= 400
      raise BadRequestError, 'BadRequest'
    end

    orders = JSON.parse(order_resp.body)
    orders['commodities'].each do |order|
      delivery_id = order['deliveryId']
      uid = order['userId']
      delivery_url = URI("#{USER_SERVICE}/user/#{uid}/delivery_infos/#{delivery_id}")

      begin
        delivery_resp = Faraday.get(delivery_url, nil, {'token' => token})
      rescue StandardError => e
        puts e.message.to_s
      end

      if delivery_resp.status == 401
        raise UnauthorizedError, 'UnauthorizedError'
      elsif delivery_resp.status == 404
        raise NotFoundError.new('Delivery', 'NotFound')
      elsif delivery_resp.status >= 400
        raise BadRequestError, 'BadRequest'
      end

      order['delivery'] = JSON.parse(delivery_resp.body)
    end

    yajl :orders, locals: {count: orders['count'], page: orders['pgNum'], size: orders['pgSize'], orders: orders['commodities']}
  end

  put '/:id/receivestatus' do |id|
    req = JSON.parse(request.body.read)
    uid = req['userId']
    token = request.env['HTTP_TOKEN'].to_s
    user = Auth.auth!(uid, token)

    json = {status: req['status'].to_s == 'true' }.to_json
    url = URI("#{ORDER_SERVICE}/order/receivestatus/#{id}")

    begin
      resp = Faraday.put(url, json, {'Content-Type' => 'application/json'})
    rescue StandardError => e
      puts e.message.to_s
    end

    if resp.status == 401
      raise UnauthorizedError, 'UnauthorizedError'
    elsif resp.status == 404
      raise NotFoundError.new('Order', 'NotFound')
    elsif resp.status >= 400
      raise BadRequestError, 'BadRequest'
    end

    resp.body
  end

  put '/:id/sendstatus' do |id|
    req = JSON.parse(request.body.read)
    uid = req['userId']
    token = request.env['HTTP_TOKEN'].to_s
    user = Auth.auth!(uid, token)

    json = {status: req['status'].to_s == 'true' }.to_json
    url = URI("#{ORDER_SERVICE}/order/sendstatus/#{id}")

    begin
      resp = Faraday.put(url, json, {'Content-Type' => 'application/json'})
    rescue StandardError => e
      puts e.message.to_s
    end

    if resp.status == 401
      raise UnauthorizedError, 'UnauthorizedError'
    elsif resp.status == 404
      raise NotFoundError.new('Order', 'NotFound')
    elsif resp.status >= 400
      raise BadRequestError, 'BadRequest'
    end

    resp.body
  end
end
