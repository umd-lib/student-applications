# A particular skill of an applicant
class Skill < ActiveRecord::Base
  has_and_belongs_to_many :prospect
end
