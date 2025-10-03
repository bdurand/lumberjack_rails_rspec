# frozen_string_literal: true

require "stringio"

require_relative "../lib/lumberjack_rails_rspec"

module Rails
  @logger = nil
  @original_logger = nil

  class << self
    attr_reader :logger
    attr_reader :original_logger

    def logger=(logger)
      @logger = if logger.is_a?(ActiveSupport::BroadcastLogger)
        logger
      else
        ActiveSupport::BroadcastLogger.new(logger)
      end
    end

    def original_logger=(logger)
      @original_logger = logger
      self.logger = logger
    end
  end
end

Rails.original_logger = Lumberjack::Logger.new(:test)

Lumberjack.deprecation_mode = :raise

RSpec.configure do |config|
  config.warnings = true
  config.disable_monkey_patching!
  config.default_formatter = "doc" if config.files_to_run.one?
  config.order = :random
  Kernel.srand config.seed

  config.around(:each, :deprecation_mode) do |example|
    Lumberjack::Utils.with_deprecation_mode(example.metadata[:deprecation_mode]) do
      example.run
    end
  end
end
