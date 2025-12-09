source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Use .ruby-version for the Ruby version to use with the application
# ruby '3.3.8'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 7.0.10'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 1.4'
# Use Puma as the app server
gem 'puma', '~> 5.0'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
# gem 'webpacker', '~> 5.0'

# Use Uglifier as compressor for JavaScript assets, instead of webpacker
gem 'uglifier', '>= 1.3.0'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

# Use Postgres in production
gem 'pg', group: :production

# jquery
gem 'jquery-rails'

# dotenv - For storing production configuration parameters
gem 'dotenv-rails', '~> 2.7.6'

# Pagination
gem 'will_paginate', '~> 3.1.0'
gem 'will_paginate-bootstrap'

# UMD Bootstrap style
gem 'umd_lib_style', github: 'umd-lib/umd_lib_style', ref: '2.0.0'

# CAS authentication
gem 'rack-cas'

gem 'figaro'

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

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'pry-rails'
  gem 'faker'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'guard', require: false
  gem 'guard-minitest', require: false
  gem 'rb-fsevent', require: false
  gem 'terminal-notifier-guard', require: false

  # Code analysis tools
  gem 'rubocop', '= 1.26.1', require: false
  gem 'rubocop-rails', '= 2.14.2', require: false
  gem 'rubocop-checkstyle_formatter', require: false
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver', '>= 4.0.0.rc1'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
  gem 'connection_pool'
  gem 'launchy'
  gem 'minitest'
  gem 'minitest-reporters'
  gem 'mocha', '~> 2.0'
  gem 'rack_session_access'
  gem 'rails-controller-testing'
  gem 'shoulda-context'
  gem 'shoulda-matchers', '>= 3.0.1'

  gem 'simplecov', require: false
  gem 'simplecov-rcov', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
