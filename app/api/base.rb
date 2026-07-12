# frozen_string_literal: true

# Root Grape API for Resobot.
class Base < Grape::API
  format :json

  mount ::Health
  mount ::Resdb
end
