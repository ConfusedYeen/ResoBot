# frozen_string_literal: true

# Resdb endpoint for the API.
class Resdb < Grape::API
  format :json

  namespace :resdb do
    get do
      { status: 'ok', message: 'Resdb is working' }
    end

    params do
      requires :url, type: String, desc: 'Asset URL'
      optional :name, type: String, desc: 'User Name'
      optional :datetime, type: String, desc: 'Initial send Datetime'
      optional :location, type: String, desc: 'Instance name'
    end
    post :image do
      Resdb::Process.new.call(declared(params))
    end
  end
end
