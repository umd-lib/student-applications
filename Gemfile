source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.2.3"
# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"
# Use sqlite3 as the database for Active Record
gem "sqlite3", ">= 1.4"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# UMD Customization
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# End UMD Customization

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# UMD Customization
# Use Postgres in production
gem 'pg', group: :production

# jquery
gem 'jquery-rails'

# dotenv - For storing production configuration parameters
gem 'dotenv-rails', '~> 2.7.6'

# Pagination
gem 'will_paginate', '~> 4.0.0'
gem 'will_paginate-bootstrap'

# UMD Bootstrap style
gem 'umd_lib_style', github: 'umd-lib/umd_lib_style', ref: '2.0.0'

# CAS authentication
gem 'rack-cas'

gem 'bootstrap-toggle-rails'
gem 'cocoon'

# Pin "country_select" to v8.0.3, as it currently causes system tests to fail
# when using a later version. This pinned version should be re-evaluated when
# upgrading to later Rails and Ruby versions.
gem 'country_select', '~> 8.0.3'
gem 'simple_form', '~> 5.1.0'

gem 'daemons'
gem 'delayed_job_active_record'
gem 'delayed_job_web'

gem 'active_storage_validations', '0.9.7'

# "prawn" gem is used by the auto-loaded "lib/sample_prospect_creator.rb",
# and so needs to be part of the production gemset, in order to Rake tasks
# to run in production.
gem 'prawn', '>= 2.4.0', require: false
# End UMD Customization

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
  
  # UMD Customization
  gem 'faker'
  # End UMD Customization
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # UMD Customization
  gem 'rubocop-checkstyle_formatter', require: false
  # End UMD Customization
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"

  # UMD Customization
  gem 'minitest'
  gem 'minitest-reporters'
  gem 'mocha', '~> 2.0'
  gem 'rack_session_access'
  gem 'rails-controller-testing'
  gem 'shoulda-context'
  gem 'shoulda-matchers', '>= 3.0.1'

  gem 'simplecov', require: false
  gem 'simplecov-rcov', require: false
  # End UMD Customization
end
