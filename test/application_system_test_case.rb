# frozen_string_literal: true

require 'test_helper'

# Abstract base class for system tests
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  Capybara.register_driver :chrome_headless do |app|
    Selenium::WebDriver::Chrome::Service.driver_path = 'chromedriver/chromedriver'

    options = ::Selenium::WebDriver::Chrome::Options.new

    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--window-size=1400,1400')

    Capybara::Selenium::Driver.new(app, browser: :chrome, capabilities: options)
  end

  #  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
  driven_by :chrome_headless
end
