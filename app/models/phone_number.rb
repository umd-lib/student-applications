class PhoneNumber < ActiveRecord::Base
  belongs_to :prospect
  validates :prospect, presence: true

  enum phone_type: %i( local cell other )
end
