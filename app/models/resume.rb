# This is a model for a application
# It includes the steps that are used to submit one
class Resume < ActiveRecord::Base
  has_attached_file :file
  validates_attachment_content_type :file, content_type: /\Aapplication\/pdf\z/

  has_one :prospect
end
