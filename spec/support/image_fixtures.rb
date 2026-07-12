# frozen_string_literal: true

module ImageFixtures
  FIXTURES_DIR = Rails.root.join('spec/fixtures/files')

  module_function

  def path_for(name)
    FIXTURES_DIR.join(name)
  end

  def ensure_fixtures!
    FileUtils.mkdir_p(FIXTURES_DIR)
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    ImageFixtures.ensure_fixtures!
  end
end
