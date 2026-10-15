# frozen_string_literal: true

module General
  # Downloads an asset from a URL.
  class DownloadAsset
    include HTTParty

    def call(url = nil, allowed_types: nil)
      return false if url.nil?

      response = HTTParty.get(url)
      return false unless response.success?

      content_type = response.headers['content-type']&.split(';')&.first&.strip # rubocop:disable Style/SafeNavigationChainLength
      return false if allowed_types.present? && !allowed_type?(content_type, allowed_types)

      tempfile = Tempfile.new(['asset', extension_for(content_type)])
      tempfile.binmode
      tempfile.write(response.body.b)
      tempfile.rewind

      tempfile
    end

    private

    def extension_for(content_type)
      return '' if content_type.blank?

      Rack::Mime::MIME_TYPES.invert[content_type] || ''
    end

    def allowed_type?(content_type, allowed_types)
      allowed_types.any? do |allowed|
        if allowed.end_with?('/*')
          content_type.start_with?(allowed.delete_suffix('*'))
        else
          content_type == allowed
        end
      end
    end
  end
end
