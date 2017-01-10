# This is a model for a application
# It includes the steps that are used to submit one
class Resume < ActiveRecord::Base
  has_attached_file :file

  # fix up the MIME type using server-side detection, to overcome browsers
  # sometimes sending incorrect Content-Type headers with PDF files
  # adapted from http://stackoverflow.com/a/7000208/5124907
  GENERIC_CONTENT_TYPES = ["application/force-download", "application/octet-stream"]

  before_validation(:on => [:create, :update]) do |resume|
    if GENERIC_CONTENT_TYPES.include?(resume.file_content_type)
      mime_type = MIME::Types.type_for(resume.file_file_name)
      resume.file_content_type = mime_type.first.content_type if mime_type.first
    end
  end

  validates_attachment :file, content_type: { content_type: 'application/pdf' }

  has_one :prospect
end
