# Addresses that are associated to the Prosect
class Address < ActiveRecord::Base
  belongs_to :prospect
  validates :prospect, presence: true
  enum address_type: %i(local permanent)

  %i(street_address_1 city  postal_code address_type).each do |attr|
    validates attr, presence: true, if: ->(a) { a.prospect && a.prospect.current_step == 'contact_info' }
  end
end
