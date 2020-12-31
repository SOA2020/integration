COMMENT_ROUTE = proc do
  get '/:id/comments' do |id|
    page = (params[:page] || 1).to_i
    size = (params[:size] || 10).to_i
    url = URI("#{COMMENT_SERVICE}/#{id}/comments?page=#{page}&size=#{size}")

    begin
      resp = Faraday.get(url)
    rescue StandardError => e
      puts e.message.to_s
    end

    if resp.status == 401
      raise UnauthorizedError, 'UnauthorizedError'
    elsif resp.status == 404
      raise NotFoundError.new('Comment', 'NotFound')
    elsif resp.status >= 400
      raise BadRequestError, 'BadRequest'
    end

    resp.body
  end

  post '/:id/comments' do |id|
    req = JSON.parse(request.body.read)
    token = request.env['HTTP_TOKEN'].to_s
    uid = req['userId']
    Auth::auth!(uid, token)
    url = URI("#{COMMENT_SERVICE}/#{id}/comments")

    json = { userId: req['userId'].to_s, content: req['content'].to_s }.to_json
    begin
      resp = Faraday.post(url, json)
    rescue StandardError => e
      puts e.message.to_s
    end

    if resp.status == 401
      raise UnauthorizedError, 'UnauthorizedError'
    elsif resp.status == 404
      raise NotFoundError.new('Comment', 'NotFound')
    elsif resp.status >= 400
      raise BadRequestError, 'BadRequest'
    end

    resp.body
  end

  delete '/:id/comments/:comment_id' do |id, comment_id|
    token = request.env['HTTP_TOKEN'].to_s
    uid = params['userId']
    Auth::admin!(uid, token)
    url = URI("#{COMMENT_SERVICE}/#{id}/comments/#{comment_id}")

    begin
      resp = Faraday.delete(url)
    rescue StandardError => e
      puts e.message.to_s
    end

    if resp.status == 401
      raise UnauthorizedError, 'UnauthorizedError'
    elsif resp.status == 404
      raise NotFoundError.new('Comment', 'NotFound')
    elsif resp.status >= 400
      raise BadRequestError, 'BadRequest'
    end

    resp.body
  end
end
