require 'test_helper'

class ResumeTest < ActiveSupport::TestCase
  
  test 'can create a valid resume' do
    resume = Resume.new
    refute resume.valid?
    resume.file = File.new('test/fixtures/resume.pdf', 'r')
    assert user.valid?
  end

  test 'it only allows pdfs' do
    resume = Resume.new( file:  File.new('test/fixtures/resume.pdf', 'r')) 
    assert user.valid?
    resume.file_content_type = "bark/meow"
    refute resume.valid?
  end


end
