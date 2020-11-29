# frozen_string_literal: true

ROOT_ROUTE = proc do
  get '' do
    { status: 'running' }.to_json
  end
end
