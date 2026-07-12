# frozen_string_literal: true

class Resdb
  # Processes incoming ResDB asset submissions.
  class Process
    include HTTParty

    RESO_ASSETS_URL = ENV.fetch('RESO_ASSETS_URL', 'https://assets.resonite.com')
    TELEGRAM_API_URL = ENV.fetch('TELEGRAM_API_URL', 'https://api.telegram.org/bot')
    TELEGRAM_CHAT_ID = ENV.fetch('TELEGRAM_CHAT_ID')
    TELEGRAM_MESSAGE_THREAD_ID = ENV.fetch('TELEGRAM_MESSAGE_THREAD_ID', nil)
    TELEGRAM_BOT_TOKEN = ENV.fetch('TELEGRAM_BOT_TOKEN')

    def call(params)
      resdb_url = parse_url(params[:url])
      return { error: 'Invalid URL' } unless resdb_url

      original = download_asset(resdb_url)
      return { error: 'Failed to download asset' } unless original

      photo = PhotoCompressor.new.call(original)
      return { error: 'Failed to compress image for Telegram photo' } unless photo

      photo_response = send_photo(photo, params)
      return photo_response if photo_response[:error]

      document_response = send_document(original)

      {
        status: 'ok',
        photo: photo_response,
        document: document_response
      }
    end

    private

    def parse_url(url)
      return false unless url.starts_with?('resdb://')

      asset_id = url.split('resdb://').last.delete_prefix('/')
      asset_id = asset_id.split('.').first

      "#{RESO_ASSETS_URL}/#{asset_id}"
    end

    def download_asset(url)
      response = HTTParty.get(url)
      return false unless response.success?

      tempfile = Tempfile.new(['asset', File.extname(url)])
      tempfile.binmode
      tempfile.write(response.body.b)
      tempfile.rewind

      tempfile
    end

    def send_photo(asset, params)
      asset.rewind
      telegram_post(
        'sendPhoto',
        chat_id: TELEGRAM_CHAT_ID,
        message_thread_id: TELEGRAM_MESSAGE_THREAD_ID,
        photo: asset,
        caption: generate_caption(params)
      )
    end

    def send_document(asset)
      asset.rewind
      telegram_post(
        'sendDocument',
        chat_id: TELEGRAM_CHAT_ID,
        message_thread_id: TELEGRAM_MESSAGE_THREAD_ID,
        document: asset,
        caption: 'Original document'
      )
    end

    def telegram_post(method, body)
      response = HTTParty.post(
        "#{TELEGRAM_API_URL}#{TELEGRAM_BOT_TOKEN}/#{method}",
        body:
      )

      unless response.success?
        message = response.parsed_response['description'] || 'Unknown error'
        return { error: "Failed to send to telegram, code: #{response.code}, message: #{message}" }
      end

      { status: 'ok', message: 'Asset sent to telegram successfuwully' }
    rescue StandardError => e
      { error: "Failed to send to telegram, message: #{e.message}" }
    end

    def generate_caption(params)
      string = ''
      string += "Here's your image! uwu \n"
      string += "Submitted by: #{params[:name]}\n" if params[:name].present?
      string += "From: #{params[:location]}\n" if params[:location].present?
      string += if params[:datetime].present?
                  "Submitted at: #{params[:datetime]}\n"
                else
                  "Submitted at: #{Time.current.strftime('%Y-%m-%d %H:%M:%S')}\n"
                end
      string
    end
  end
end
