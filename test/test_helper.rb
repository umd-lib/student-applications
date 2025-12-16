# UMD Customization
require "simplecov"
require "simplecov-rcov"

SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::RcovFormatter
]
SimpleCov.start

require "securerandom"
# End UMD Customization

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# UMD Customization
require "mocha/minitest"

# Improved Minitest output (color and progress bar)
require "minitest/reporters"

if ENV["CI"].present?
  # Minitest Reporters used Jenkins/CI
  # Override JUnitReporter configuration to not empty the test/reports directory
  # between runs, so that unit and system tests reports can be combined.
  Minitest::Reporters.use! [ Minitest::Reporters::JUnitReporter.new("test/reports", false) ]
else
  # Minitest Reporters used for the local development environment
  # add  Minitest::Reporters::SpecReporter.new to first param if you want to see
  # what's running so slow.
  Minitest::Reporters.use!(
    # Minitest::Reporters::SpecReporter.new,
    Minitest::Reporters::ProgressReporter.new,
    ENV,
    Minitest.backtrace_filter
  )
end

require "rack_session_access/capybara"

# Suppress puma start/version output when running tests
Capybara.server = :puma, { Silent: true } # To clean up your test output
# End UMD Customization

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    # UMD Customization
    # Disabling parallelization, because it confuses SimpleCov
    # See https://github.com/simplecov-ruby/simplecov/issues/718
    # parallelize(workers: :number_of_processors)
    # End UMD Customization

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...

    # UMD Customization
    # this returns a hash of a fixture with an existing fixture with a random
    # directory_id to pass validations
    def dup_fixture
      fixture = prospects(:all_valid)
      fixture.directory_id = SecureRandom.hex
      fixture
    end
    # End UMD Customization
  end
end

# UMD Customization
def drag_until(locator, options = {}, &block)
  slider = find(locator)
  event_input = slider.native
  page.driver.browser.action
      .click_and_hold(event_input)
      .move_by(options[:by], 0).release
      .perform until block.call(slider["aria-valuenow"].to_i)
  slider
end
# End UMD Customization
