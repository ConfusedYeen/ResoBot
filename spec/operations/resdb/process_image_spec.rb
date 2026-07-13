# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resdb::ProcessImage do
  subject(:processor) { described_class.new.call(params) }

  let(:asset_id) { SecureRandom.uuid }
  let(:params) do
    {
      url: "resdb:///#{asset_id}.png",
      name: 'Yeener',
      datetime: Time.current.strftime('%Y-%m-%d %H:%M:%S')
    }
  end
  let(:asset_url) do
    "https://assets.resonite.com/#{asset_id}"
  end
  let(:image_body) { File.binread(ImageFixtures.path_for('small.png')) }
  let(:telegram_success) do
    instance_double(
      HTTParty::Response,
      success?: true,
      parsed_response: { 'ok' => true }
    )
  end

  before do
    allow(HTTParty).to receive(:get).with(asset_url).and_return(
      instance_double(
        HTTParty::Response,
        success?: true,
        body: image_body,
        headers: { 'content-type' => 'image/png' }
      )
    )
    allow(HTTParty).to receive(:post).and_return(telegram_success)
  end

  describe '#call' do
    it 'returns an error for non-resdb URLs' do
      processor = described_class.new.call(params.merge(url: 'https://example.com/asset.png'))

      expect(processor).to eq({ error: 'Invalid URL' })
    end

    it 'returns an error when the asset download fails' do
      allow(HTTParty).to receive(:get).with(asset_url).and_return(
        instance_double(
          HTTParty::Response,
          success?: false,
          body: '',
          headers: {}
        )
      )

      expect(processor).to eq({ error: 'Failed to download asset' })
    end

    it 'returns an error when Telegram photo upload fails', :aggregate_failures do
      allow(HTTParty).to receive(:post).with(
        a_string_including('/sendPhoto'),
        anything
      ).and_return(
        instance_double(
          HTTParty::Response,
          success?: false,
          code: 400,
          parsed_response: { 'description' => 'Bad Request: chat not found' }
        )
      )

      expect(processor[:error]).to include('Failed to send message to telegram')
      expect(processor[:error]).to include('chat not found')
    end

    it 'sends a compressed photo and the original document', :aggregate_failures do
      expect(processor)
        .to eq(
          {
            status: 'ok',
            photo: { message: 'Asset sent to telegram successfully', status: 'ok' },
            document: { message: 'Asset sent to telegram successfully', status: 'ok' }
          }
        )

      expect(HTTParty).to have_received(:post).with(
        a_string_including('/sendPhoto'),
        hash_including(:body)
      )
      expect(HTTParty).to have_received(:post).with(
        a_string_including('/sendDocument'),
        hash_including(:body)
      )
    end

    it 'includes submitter details in the photo caption' do
      processor

      expect(HTTParty).to have_received(:post).with(
        a_string_including('/sendPhoto'),
        hash_including(
          body: hash_including(
            caption: a_string_including(
              params[:name],
              DateTime.parse(params[:datetime]).strftime('%Y-%m-%d %H:%M')
            )
          )
        )
      )
    end
  end
end
