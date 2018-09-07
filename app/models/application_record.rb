# frozen_string_literal: true

# Abstract class for models
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
