# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lumberjack::Rails::RSpec::HaveLoggedMatcher do
  describe "#matches?" do
    context "when given a logger" do
      it "returns true if the expected log entry is found" do
        Rails.logger.info("User logged in", user_id: 123)

        matcher = Lumberjack::Rails::RSpec::HaveLoggedMatcher.new(severity: :info, message: "User logged in", attributes: {user_id: 123})
        expect(matcher.matches?(Rails.logger)).to be true
      end

      it "returns false if the expected log entry is not found" do
        Rails.logger.info("User logged in", user_id: 123)

        matcher = Lumberjack::Rails::RSpec::HaveLoggedMatcher.new(severity: :error, message: "Error occurred")
        expect(matcher.matches?(Rails.logger)).to be false
      end
    end

    context "when given a block" do
      it "returns true if the expected log entry is found" do
        matcher = Lumberjack::Rails::RSpec::HaveLoggedMatcher.new(severity: :info, message: "User logged in", attributes: {user_id: 123})

        result = matcher.matches?(proc {
          Rails.logger.info("User logged in", user_id: 123)
        })

        expect(result).to be true
      end

      it "returns false if the expected log entry is not found" do
        matcher = Lumberjack::Rails::RSpec::HaveLoggedMatcher.new(severity: :error, message: "Error occurred")

        result = matcher.matches?(proc {
          Rails.logger.info("User logged in", user_id: 123)
        })

        expect(result).to be false
      end
    end
  end
end
