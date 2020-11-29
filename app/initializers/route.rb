# frozen_string_literal: true

class Route < Sinatra::Base
  set :show_exceptions, :after_handler
  register Sinatra::Namespace
  use Rack::Cors do
    allow do
      origins '*'
      resource '/*',
               methods: %i[get post delete put patch options head],
               headers: :any,
               expose: ['Token'],
               max_age: 600
    end
  end

  namespace '/', &ROOT_ROUTE

  error 500 do |error|
    [
      500,
      {
        exception: error.class,
        message: error.message,
        backtrace: error.backtrace
      }.to_json
    ]
  end

  error BaseError, &:rack
end
