# frozen_string_literal: true

# This is a model for a application
# It includes the steps that are used to submit one
class Resume < ApplicationRecord
  has_one_attached :file

  validates :file, attached: true, content_type: "application/pdf"

  has_one :prospect # rubocop:disable Rails/HasManyOrHasOneDependent
end
