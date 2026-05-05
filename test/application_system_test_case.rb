require "test_helper"

# Load support files from "test/system/support"
Dir[Rails.root.join("test/system/support/**/*.rb")].sort.each { |f| require f }

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include SystemTestHelpers
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ] do |driver_option|
    driver_option.add_argument("disable-gpu")
    driver_option.add_argument("no-sandbox")
    driver_option.add_argument("disable-dev-shm-usage")
  end
end
