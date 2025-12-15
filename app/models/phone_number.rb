# frozen_string_literal: true

# A phone number for the prospect
class PhoneNumber < ApplicationRecord
  belongs_to :prospect

  validates :number, presence: true, if: ->(a) { a.prospect && a.prospect.current_step == "contact_info" }

  enum phone_type: { local: 0, cell: 1, other: 2 }
end
