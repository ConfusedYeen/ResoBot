# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resdb::PhotoCompressor do
  subject(:compressor) { described_class.new.call(asset) }

  describe '#call' do
    context 'when the asset is a small image' do
      let(:asset) { tempfile_copy(ImageFixtures.path_for('small.png')) }

      it 'returns the original file', :aggregate_failures do
        expect(compressor).to eq(asset)
        expect(compressor.size).to be <= described_class::MAX_PHOTO_SIZE
      end
    end

    context 'when the asset is a large image' do
      let(:asset) { tempfile_copy(ImageFixtures.path_for('large.png')) }

      it 'compresses large images below the 10 MB limit', :aggregate_failures do
        expect(asset.size).to be > described_class::MAX_PHOTO_SIZE

        expect(compressor).not_to eq(asset)
        expect(compressor.size).to be <= described_class::MAX_PHOTO_SIZE
        expect(File.extname(compressor.path)).to eq('.jpg')
      end
    end
  end

  def tempfile_copy(fixture_path)
    tempfile = Tempfile.new(['asset', File.extname(fixture_path)])
    tempfile.binmode
    tempfile.write(File.binread(fixture_path))
    tempfile.rewind
    tempfile
  end
end
