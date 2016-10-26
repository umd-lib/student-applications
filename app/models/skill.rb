# A particular skill of an applicant
class Skill < ActiveRecord::Base
  has_and_belongs_to_many :prospect

  scope :promoted, -> { where(promoted: true) }

  def unpromoted
    !promoted?
  end
end
