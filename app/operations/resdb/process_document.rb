# frozen_string_literal: true

# Resdb related operations
class Resdb
  # Processes incoming ResDB document submissions
  class ProcessDocument
    TELEGRAM_CHAT_ID = ENV.fetch('TELEGRAM_CHAT_ID', nil)
    TELEGRAM_MESSAGE_THREAD_ID = ENV.fetch('TELEGRAM_MESSAGE_THREAD_ID', nil)

    def call(params)
      return { error: 'Fill your env file lul' } if ENV['TELEGRAM_CHAT_ID'].nil?

      resdb_url = CloudUrlParser.new.call(params[:url])
      return { error: 'Invalid URL' } unless resdb_url

      original = General::DownloadAsset.new.call(resdb_url)
      return { error: 'Failed to download asset' } unless original

      document_response = send_document(original)
      return document_response if document_response[:error]

      {
        status: 'ok',
        document: document_response
      }
    end
  end

  private

  def send_document(asset)
    Telegram::SendMessageToAPI.new.call(
      'sendDocument',
      {
        chat_id: TELEGRAM_CHAT_ID,
        message_thread_id: TELEGRAM_MESSAGE_THREAD_ID,
        document: asset,
        caption: "Here's your document! uwu"
      },
      :post
    )
  end
end
