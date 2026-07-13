# frozen_string_literal: true

class Resdb
  # Processes incoming ResDB image submissions.
  class ProcessImage
    include HTTParty

    TELEGRAM_CHAT_ID = ENV.fetch('TELEGRAM_CHAT_ID', nil)
    TELEGRAM_MESSAGE_THREAD_ID = ENV.fetch('TELEGRAM_MESSAGE_THREAD_ID', nil)

    def call(params)
      return { error: 'Fill your env file lul' } if ENV['TELEGRAM_CHAT_ID'].nil?

      resdb_url = CloudUrlParser.new.call(params[:url])
      return { error: 'Invalid URL' } unless resdb_url

      original = General::DownloadAsset.new.call(resdb_url, allowed_types: %w[image/*])
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

    def send_photo(asset, params)
      Telegram::SendMessageToAPI.new.call(
        'sendPhoto',
        {
          chat_id: TELEGRAM_CHAT_ID,
          message_thread_id: TELEGRAM_MESSAGE_THREAD_ID,
          photo: asset,
          caption: caption_text(params)
        },
        :post
      )
    end

    def send_document(asset)
      Telegram::SendMessageToAPI.new.call(
        'sendDocument',
        {
          chat_id: TELEGRAM_CHAT_ID,
          message_thread_id: TELEGRAM_MESSAGE_THREAD_ID,
          document: asset,
          caption: 'Original document'
        },
        :post
      )
    end

    def caption_text(params = {})
      string = ''
      string += "Here's your image! uwu \n"
      string += "Submitted by: #{params[:name]}\n" if params[:name].present?
      string += "From: #{params[:location]}\n" if params[:location].present?
      string += if params[:datetime].present?
                  "Submitted at: #{DateTime.parse(params[:datetime]).strftime('%Y-%m-%d %H:%M')}\n"
                else
                  "Submitted at: #{DateTime.current.strftime('%Y-%m-%d %H:%M')}\n"
                end
      string
    end
  end
end
