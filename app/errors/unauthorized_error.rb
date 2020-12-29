# frozen_string_literal: true

class UnauthorizedError < BaseError
  def initialize(reason)
    super(401, {
      reason: reason
    })
  end
end
