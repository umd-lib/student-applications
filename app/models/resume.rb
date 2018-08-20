# This is a model for a application
# It includes the steps that are used to submit one
class Resume < ActiveRecord::Base
  has_attached_file :file

  validates_attachment_presence :file
  validates_attachment :file, content_type: { content_type: 'application/pdf' }

  has_one :prospect
end
