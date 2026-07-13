# frozen_string_literal: true

class Resdb
  # Parses incoming ResDB cloud URLs.
  class CloudUrlParser
    RESO_ASSETS_URL = ENV.fetch('RESO_ASSETS_URL', 'https://assets.resonite.com')

    def call(url)
      return false unless url.starts_with?('resdb://')

      asset_id = url.split('resdb://').last.delete_prefix('/')
      asset_id = asset_id.split('.').first

      "#{RESO_ASSETS_URL}/#{asset_id}"
    end
  end
end
