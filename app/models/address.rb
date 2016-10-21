# Addresses that are associated to the Prosect
class Address < ActiveRecord::Base

  belongs_to :prospect
  validates :prospect, presence: true   
  enum address_type: %i{ local permanent } 

  %i( street_address_1 city state postal_code address_type ).each do |attr|
    validates_presence_of attr, if: ->(a) {  a.prospect && a.prospect.current_step == "contact_info"  } 
  end

end
