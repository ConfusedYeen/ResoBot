# frozen_string_literal: true

require 'vips'

class Resdb
  # Compresses images to fit Telegram's sendPhoto size limit.
  class PhotoCompressor
    MAX_PHOTO_SIZE = 10 * 1024 * 1024
    MAX_DIMENSION = 4096
    MIN_JPEG_QUALITY = 40
    IMAGE_EXTENSIONS = %w[.png .jpg .jpeg .webp .gif .bmp .tif .tiff].freeze

    def call(asset)
      asset.rewind
      return asset unless image?(asset)
      return asset if asset.size <= MAX_PHOTO_SIZE

      compress_image(asset)
    end

    private

    def image?(asset)
      IMAGE_EXTENSIONS.include?(File.extname(asset.path).downcase)
    end

    def compress_image(asset)
      try_qualities(limit_dimensions(Vips::Image.new_from_file(asset.path, access: :sequential)), 85)
    end

    def try_qualities(image, quality)
      loop do
        compressed = write_jpeg_tempfile(image, quality:)
        return compressed if compressed.size <= MAX_PHOTO_SIZE

        quality -= 10
        next if quality >= MIN_JPEG_QUALITY

        return false unless shrinkable?(image)

        image = image.resize(512.0 / [image.width, image.height].max)
        quality = 85
      end
    end

    def shrinkable?(image)
      [image.width, image.height].max > 512
    end

    def limit_dimensions(image)
      longest_side = [image.width, image.height].max
      return image if longest_side <= MAX_DIMENSION

      image.resize(MAX_DIMENSION.to_f / longest_side)
    end

    def write_jpeg_tempfile(image, quality:)
      tempfile = Tempfile.new(['compressed', '.jpg'])
      tempfile.binmode
      image.jpegsave(tempfile.path, Q: quality, strip: true)
      tempfile.rewind
      tempfile
    end
  end
end
