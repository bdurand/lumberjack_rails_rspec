# frozen_string_literal: true

# RSpec matcher for checking logs for specific entries in a logger.
class Lumberjack::Rails::RSpec::HaveLoggedMatcher < Lumberjack::RSpec::IncludeLogEntryMatcher
  # Match either a logger or a block that produces logs. If a block is given, it is
  # called and the Rails.logger is used for matching. This allows using the matcher
  # with block expectations.
  #
  # @param actual [Lumberjack::Logger, Proc] The logger to check or a block that produces logs.
  # @return [Boolean] True if the expected log entry is found, false otherwise.
  def matches?(actual)
    logger = if actual.is_a?(Proc)
      actual.call
      Rails.logger
    else
      actual
    end

    super(logger)
  end

  def supports_block_expectations?
    true
  end

  # Support for chaining expectations with `and`.
  def and(matcher = nil)
    if matcher
      # When called with another matcher, create a compound matcher
      RSpec::Matchers::BuiltIn::Compound::And.new(self, matcher)
    else
      # When called without arguments, return self for fluent interface
      self
    end
  end
end
