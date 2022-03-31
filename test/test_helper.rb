# frozen_string_literal: true

require 'simplecov'
require 'simplecov-rcov'

SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::RcovFormatter
]
SimpleCov.start

require 'securerandom'

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'mocha/minitest'

# Improved Minitest output (color and progress bar)
require 'minitest/reporters'

# add  Minitest::Reporters::SpecReporter.new to first param if you want to see
# what's running so slow.
Minitest::Reporters.use!(
  # Minitest::Reporters::SpecReporter.new,
  Minitest::Reporters::ProgressReporter.new,
  ENV,
  Minitest.backtrace_filter
)

require 'rack_session_access/capybara'

# Suppress puma start/version output when running tests
Capybara.server = :puma, { Silent: true } # To clean up your test output

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  # Disabling parallelization, because it confuses SimpleCov
  # See https://github.com/simplecov-ruby/simplecov/issues/718
  # parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

  # this returns a hash of a fixture with an existing fixture with a random
  # directory_id to pass validations
  def dup_fixture
    fixture = prospects(:all_valid)
    fixture.directory_id = SecureRandom.hex
    fixture
  end
end

def drag_until(locator, options = {}, &block)
  slider = find(locator)
  event_input = slider.native
  page.driver.browser.action
      .click_and_hold(event_input)
      .move_by(options[:by], 0).release
      .perform until block.call(slider['aria-valuenow'].to_i)
  slider
end
