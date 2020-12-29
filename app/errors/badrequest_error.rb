# frozen_string_literal: true

class BadRequestError < BaseError
  def initialize(reason)
    super(400, {
      reason: reason
    })
  end
end
