# frozen_string_literal: true

# Health check endpoint for the API.
class Health < Grape::API
  desc 'Health check'
  get :health do
    { status: 'ok' }
  end
end
