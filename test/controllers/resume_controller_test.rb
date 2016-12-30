require 'test_helper'

class ResumesControllerTest < ActionController::TestCase

  test 'should create a new resume' do
    assert_difference( 'Resume.count' ) do
      post :create, resume: { file_file_name: "test-pdf" }
    end
  end

  test 'should allow anyone to view an unsubmitted resume' do
    resume = Resume.create(file: File.new('test/fixtures/resume.pdf', 'r'))
    get :show, id: resume.id
    assert_response :success
  end
  
  test 'should not allow anyone to view a submitted resume' do
    prospect = prospects(:all_valid) 
    prospect.build_resume( file: File.new('test/fixtures/resume.pdf', 'r'))
    prospect.save

    get :show, id: prospect.resume_id
    assert_response(403)
  end
  
  test 'should allow authed users to view a submitted resume' do
    prospect = prospects(:all_valid) 
    prospect.build_resume( file: File.new('test/fixtures/resume.pdf', 'r'))
    prospect.save

    session[:cas] = { user: "admin" }
    get :show, id: prospect.resume_id
    assert_response :success
  end



end
