# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lumberjack::RSpec do
  describe "VERSION" do
    it "has a version number" do
      expect(Lumberjack::RSpec::VERSION).not_to be nil
    end
  end

  describe "have_logged" do
    it "matches log entries" do
      Rails.logger.info("Test log message")
      expect(Rails.logger).to have_logged(message: "Test log message")
    end

    it "matches negatively" do
      Rails.logger.info("Another log message")
      expect(Rails.logger).not_to have_logged(message: "Nonexistent message")
    end

    it "works with block expectations" do
      expect {
        Rails.logger.warn("Block log message")
      }.to have_logged(severity: :warn, message: "Block log message")
    end

    it "supports chaining with and" do
      Rails.logger.error("First error", code: 500)
      Rails.logger.error("Second error", code: 501)

      expect(Rails.logger).to have_logged(message: "First error").and have_logged(message: "Second error")
    end

    it "supports chaining with a block expectation" do
      expect {
        Rails.logger.debug("Debug message")
        Rails.logger.info("Info message")
      }.to have_logged(message: "Debug message").and have_logged(message: "Info message")
    end
  end
end
