# frozen_string_literal: true

require 'rails_helper'

RSpec.describe General::DownloadAsset do
  subject(:download) { described_class.new.call(url, allowed_types:) }

  let(:url) { 'https://example.com/assets/sample' }
  let(:allowed_types) { nil }
  let(:image_body) { File.binread(ImageFixtures.path_for('small.png')) }

  describe '#call' do
    it 'returns false when the url is nil' do
      expect(described_class.new.call(nil)).to be(false)
    end

    it 'returns false when the download fails' do
      allow(HTTParty).to receive(:get).with(url).and_return(
        instance_double(HTTParty::Response, success?: false)
      )

      expect(download).to be(false)
    end

    it 'assigns the matching file extension' do
      allow(HTTParty).to receive(:get).with(url).and_return(
        instance_double(
          HTTParty::Response,
          success?: true,
          body: image_body,
          headers: { 'content-type' => 'image/png' }
        )
      )

      expect(File.extname(download.path)).to eq('.png')
    end

    it 'returns false when the content type is not allowed' do
      allow(HTTParty).to receive(:get).with(url).and_return(
        instance_double(
          HTTParty::Response,
          success?: true,
          body: 'not an image',
          headers: { 'content-type' => 'text/plain' }
        )
      )

      expect(described_class.new.call(url, allowed_types: %w[image/*])).to be(false)
    end

    it 'allows non-specific content type matches' do
      allow(HTTParty).to receive(:get).with(url).and_return(
        instance_double(
          HTTParty::Response,
          success?: true,
          body: image_body,
          headers: { 'content-type' => 'image/webp' }
        )
      )

      asset = described_class.new.call(url, allowed_types: %w[image/*])

      expect(File.extname(asset.path)).to eq('.webp')
    end
  end
end
