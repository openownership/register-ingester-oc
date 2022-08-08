# frozen_string_literal: true

unless ENV['TEST'].to_i == 1
  raise 'not test env!'
end

require "register_ingester_oc"
require 'webmock/rspec'

RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length = nil

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = :random
  Kernel.srand config.seed

  WebMock.disable_net_connect!(
    allow_localhost: true,
    allow: 'chromedriver.storage.googleapis.com',
  )
end
