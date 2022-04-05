# frozen_string_literal: true

require 'test_helper'

# Unit tests for resumes
class ResumeTest < ActiveSupport::TestCase
  test 'can create a valid resume' do
    resume = Resume.new
    assert_not resume.valid?
    resume.file.attach(io: File.open('test/fixtures/files/resume.pdf'), filename: 'resume.pdf')
    assert resume.valid?
  end

  test 'it only allows pdfs' do
    resume = Resume.new(file: { io: File.open('test/fixtures/files/resume.pdf'), filename: 'resume.pdf' })
    assert resume.valid?
    resume.file.content_type = 'bark/meow'
    assert_not resume.valid?
  end
end
