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
end
