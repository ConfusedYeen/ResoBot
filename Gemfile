# frozen_string_literal: true

source 'https://rubygems.org'

ruby '4.0.5'
# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 8.1.3'
# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 5.0'
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem 'kamal', require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem 'thruster', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
# gem "rack-cors"

gem 'grape'
gem 'grape-entity' # optional, for response serialization
gem 'httparty'
gem 'ruby-vips'

group :development, :test do
  gem 'brakeman', require: false
  gem 'byebug'
  gem 'dotenv-rails'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'simplecov', require: false
end
