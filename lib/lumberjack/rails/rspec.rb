# frozen_string_literal: true

require "lumberjack"
require "lumberjack_rails"
require "lumberjack/rspec"

# RSpec helper methods for working with Lumberjack loggers.
module Lumberjack::Rails::RSpec
  VERSION = File.read(File.expand_path("../../../VERSION", __dir__)).strip.freeze

  class << self
    # Around callback to replace the Rails.logger with a test logger for the duration of the example.
    # If the example fails, the logs from the test logger are written to the original logger. This
    # helps with debugging test failures by suppressing log entries unless the test fails.
    #
    # @param example [RSpec::Core::Example] The example being run.
    # @return [void]
    def around_each(example)
      original_logger = Rails.logger
      test_device = Lumberjack::Device::Test.new
      begin
        Rails.logger = Lumberjack::Logger.new(test_device)

        example.run

        if example.exception
          puts example.exception.inspect, example.exception.backtrace
          original_logger.tag(rspec: {location: example.metadata[:location]}) do
            test_device.write_to(original_logger)
          end
        end
      ensure
        Rails.logger = original_logger
      end
    end
  end

  # Create a matcher for checking if a log entry is included in the Rails.logger logs.
  # This matcher provides better error messages than using the include? method directly
  # and supports calling with or without a block.
  #
  # @param expected_hash [Hash] The expected log entry attributes to match.
  # @option expected_hash [String, Regexp] :message The expected message content.
  # @option expected_hash [Hash] :attributes Expected log entry attributes.
  # @option expected_hash [String] :progname Expected program name.
  # @return [Lumberjack::RSpec::IncludeLogEntryMatcher] A matcher for the expected log entry.
  # @example With a block
  #   expect{ subject }.to have_logged(severity: :info, message: "User logged in")
  # @example Without a block
  #   subject
  #   expect(Rails.logger).to have_logged(message: /error/i, attributes: {user_id: 123})
  def have_logged(expected_hash)
    Lumberjack::Rails::RSpec::HaveLoggedMatcher.new(expected_hash)
  end
end

require_relative "rspec/have_logged_matcher"

begin
  require "rspec/core"

  ::RSpec.configure do |config|
    config.include Lumberjack::Rails::RSpec

    config.around(:each) do |example|
      Lumberjack::Rails::RSpec.around_each(example)
    end
  end
rescue LoadError
  # RSpec is not available, so we can't include the RSpec helpers.
end
