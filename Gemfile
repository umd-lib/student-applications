source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.6'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
# gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
gem 'capistrano-rails', group: :development

# Use Postgres in production
gem 'pg', group: :production

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# jquery
gem 'jquery-rails'

# dotenv - For storing production configuration parameters
gem 'dotenv-rails', '~> 2.5.0'

# Pagination
gem 'will_paginate', '~> 3.1.0'
gem 'will_paginate-bootstrap'

# UMD Bootstrap style
gem 'umd_lib_style', github: 'umd-lib/umd_lib_style', ref: '1.1.0'

# CAS authentication
gem 'rack-cas'

gem 'figaro'

gem 'bootstrap-toggle-rails'
gem 'cocoon'
gem 'country_select'
gem 'simple_form'

gem 'paperclip', '~> 5.3.0'

gem 'daemons'
gem 'delayed_job_active_record'
gem 'delayed_job_web'

gem 'faker'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
  gem 'pry-rails'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'guard', require: false
  gem 'guard-minitest', require: false
  gem 'rb-fsevent', require: false
  gem 'ruby_dep', '~> 1.3.1'
  gem 'terminal-notifier-guard', require: false

  # Code analysis tools
  gem 'rubocop', '= 0.49.1', require: false
  gem 'rubocop-checkstyle_formatter', require: false
end

group :test do
  gem 'connection_pool'
  gem 'launchy'
  # Pin minitest to v5.10.0, because of https://github.com/seattlerb/minitest/issues/730
  gem 'minitest', '5.10.0'
  gem 'minitest-rails-capybara'
  gem 'minitest-reporters'
  # use the head to get the callback functionality
  gem 'capybara-screenshot'
  gem 'chromedriver-helper'
  gem 'database_cleaner'
  gem 'mocha'
  gem 'rack_session_access'
  gem 'rails-controller-testing'
  gem 'shoulda-context'
  gem 'shoulda-matchers', '>= 3.0.1'

  gem 'simplecov', require: false
  gem 'simplecov-rcov', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
