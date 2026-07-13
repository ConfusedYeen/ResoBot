# frozen_string_literal: true

module Telegram
  # Sends a message to the Telegram API.
  class SendMessageToAPI
    include HTTParty

    TELEGRAM_API_URL = ENV.fetch('TELEGRAM_API_URL', 'https://api.telegram.org/bot')
    TELEGRAM_BOT_TOKEN = ENV.fetch('TELEGRAM_BOT_TOKEN')

    def call(method, body, request_type)
      response = HTTParty.send(
        request_type,
        "#{TELEGRAM_API_URL}#{TELEGRAM_BOT_TOKEN}/#{method}",
        body:
      )

      unless response.success?
        message = response.parsed_response['description'] || 'Unknown error'
        return { error: "Failed to send message to telegram, code: #{response.code}, message: #{message}" }
      end

      { status: 'ok', message: 'Asset sent to telegram successfully' }
    rescue StandardError => e
      { error: "Failed to send to telegram, message: #{e.message}" }
    end
  end
end
