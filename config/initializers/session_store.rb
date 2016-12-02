# Be sure to restart your server when you modify this file.
require 'rack-cas/session_store/rails/active_record'

Rails.application.config.session_store ActionDispatch::Session::RackCasActiveRecordStore
