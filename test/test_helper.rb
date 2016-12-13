require 'simplecov'
require 'database_cleaner'


SimpleCov.start

DatabaseCleaner.strategy = :truncation, { only: %w( prospects ) }

require 'securerandom'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'mocha/mini_test'
require 'minitest/rails/capybara'

# Improved Minitest output (color and progress bar)
require 'minitest/reporters'

# add  Minitest::Reporters::SpecReporter.new to first param if you want to see
# what's running so damn slow.
Minitest::Reporters.use!(
  # Minitest::Reporters::SpecReporter.new, 
  Minitest::Reporters::ProgressReporter.new, 
  ENV,
  Minitest.backtrace_filter
)

# Capybara and poltergeist integration
require 'capybara/rails'
require 'capybara/poltergeist'
require 'capybara-screenshot/minitest'

# for debugging
# https://github.com/teampoltergeist/poltergeist#remote-debugging-experimental
# Capybara.register_driver :poltergeist_debug do |app|
#  Capybara::Poltergeist::Driver.new(app, :inspector => true)
# end
# Capybara.javascript_driver = :poltergeist_debug

Capybara.javascript_driver = :poltergeist
require 'rack_session_access/capybara'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  self.use_transactional_fixtures = false
  # Add more helper methods to be used by all tests here...

  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end
end

class ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Capybara::Screenshot::MiniTestPlugin

  before :after do
    DatabaseCleaner.clean
    Capybara.reset_sessions!
  end
end

# See: https://gist.github.com/mperham/3049152
class ActiveRecord::Base
  mattr_accessor :shared_connection
  @shared_connection = nil

  def self.connection
    @shared_connection || ConnectionPool::Wrapper.new(size: 1) { retrieve_connection }
  end
end
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
