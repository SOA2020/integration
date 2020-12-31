module Auth
  def self.auth!(uid, token)
    url = URI("#{USER_SERVICE}/user/#{uid}")

    begin
      resp = Faraday.get(url, nil, { 'token' => token})
    rescue StandardError => e
      puts e.message.to_s
    end

    raise UnauthorizedError, 'UnauthorizedError' unless resp.status < 400
  end

  def self.admin!(uid, token)
    url = URI("#{USER_SERVICE}/user/#{uid}")

    begin
      resp = Faraday.get(url, nil, { 'token' => token})
    rescue StandardError => e
      puts e.message.to_s
    end

    raise UnauthorizedError, 'UnauthorizedError' unless resp.status < 400

    admin = JSON.parse(resp.body)['isAdmin'].to_s
    raise UnauthorizedError, 'UnauthorizedError' unless admin == 'true'
  end
end
