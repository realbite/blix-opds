require 'bundler/setup'
Bundler.setup

require 'blix/opds'  # This should require your main library file
require 'pry'

# You can require any additional test dependencies here
require 'fileutils'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Clean up any test artifacts
  config.after(:suite) do
    FileUtils.rm_rf('/tmp/opds_test')
  end
end

# If you're using SimpleCov for code coverage, you can add it here:
# require 'simplecov'
# SimpleCov.start

# If you need to set up any test data or configurations that should be available to all tests,
# you can do that here as well.

# For example, if you need to set up a test database:
# require 'blix/mongo'
# Blix::Mongo::Database.setup_test_database!

# Or if you need to set a specific configuration for your tests:
# Blix::OPDS.configure do |config|
#   config.some_setting = 'test_value'
# end