# frozen_string_literal: true

# Addresses that are associated to the Prosect
class Address < ApplicationRecord
  belongs_to :prospect
  enum address_type: { local: 0, permanent: 1 }

  %i[street_address_1 city postal_code address_type].each do |attr|
    validates attr, presence: true, if: ->(a) { a.prospect && a.prospect.current_step == "contact_info" }
  end
end
