# frozen_string_literal: true

require 'test_helper'

# Abstract base class for system tests
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  #  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
  driven_by :selenium_chrome_headless, screen_size: [1400, 1400]
end
