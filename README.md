# Lumberjack Rails RSpec

[![Continuous Integration](https://github.com/bdurand/lumberjack_rails_rspec/actions/workflows/continuous_integration.yml/badge.svg)](https://github.com/bdurand/lumberjack_rails_rspec/actions/workflows/continuous_integration.yml)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)
[![Gem Version](https://badge.fury.io/rb/lumberjack_rails_rspec.svg)](https://badge.fury.io/rb/lumberjack_rails_rspec)

This gem provides an RSpec helpers for Rails applications using the [lumberjack](https://github.com/bdurand/lumberjack) gem.

It allows you to easily verify that specific log entries were created during the execution of your code.

### Why should I test log entries?

Logging is an important part of any server based application, and observability __is__ a product feature.

You don't need to test every log entry. However, where you have important events being logged that impact monitors, metrics, or business decisions, those become critical application functionality. You should be testing that those log entries are created as expected to prevent regressions.

## Usage

### Setup

Require the rspec file in your test helper.

```ruby
require "lumberjack/rails/rspec"
```

In order to use this gem, `Rails.logger` must be a `Lumberjack::Logger` instance. See the [lumberjack_rails](https://github.com/bdurand/lumberjack_rails) gem for more information on setting up the logger.

The logs from `Rails.logger` will be captured during each example and can be asserted against.

### Assertions

You can make assertions about what has been logged using the `have_logged` matcher.

```ruby
describe MyClass do
  it "logs information" do
    subject
    expect(Rails.logger).to have_logged(message: "Something happened")
  end
end
```

You can also use the matcher with block expectations.

```ruby
describe MyClass do
  it "logs information" do
    expect { subject }.to have_logged(message: "Something happened")
  end
end
```

You can match on the message, severity, progname, or attributes of a log entry or any combination of thereof.

```ruby
it "logs with attributes" do
  subject
  expect(Rails.logger).to have_logged(
    severity: :info,
    message: "User logged in",
    attributes: { user_id: 123 }
  )
end
```

You can use regular expressions or RSpec matchers to match any of the fields.

```ruby
it "logs with a regex" do
  subject
  expect(Rails.logger).to have_logged(
    severity: :error,
    message: /failed/i,
    attributes: { status: be >= 500 }
  )
end
```

You can make assertions on attributes using either a nested hash or a flat hash with dot notation.

```ruby
it "logs with nested attributes" do
  subject
  expect(Rails.logger).to have_logged(
    message: "Order processed",
    attributes: { order: { id: 456, total: be > 0 } }
  )
end
```

### Log Output

Only log entries from failed examples will be output to the logs. This removes noise from successful tests and makes your test logs easier to read and far more useful for diagnosing failures.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "lumberjack_rails_rspec"
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install lumberjack_rails_rspec
```

## Contributing

Open a pull request on GitHub.

Please use the [standardrb](https://github.com/testdouble/standard) syntax and lint your code with `standardrb --fix` before submitting.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
