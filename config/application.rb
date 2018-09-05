require_relative 'boot'

require 'rails/all'
require 'rack-cas/session_store/active_record'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module OnlineStudentApplications
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  
    config.rack_cas.server_url = 'https://login.umd.edu/cas'
    config.rack_cas.session_store = RackCAS::ActiveRecordStore 

    config.active_job.queue_adapter = :delayed_job
  end
end
