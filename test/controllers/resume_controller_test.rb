# frozen_string_literal: true

require 'test_helper'

class ResumesControllerTest < ActionController::TestCase
  test 'should create a new resume' do
    file = fixture_file_upload('resume.pdf', 'application/pdf')
    assert_difference('Resume.count') do
      post :create, params: { resume: { file: file } }
    end
  end

  test 'should create a new resume ( even if the mime is weird )' do
    %w[application/force-download application/octet-stream application/pdf].each do |mime|
      file = fixture_file_upload('resume.pdf', mime)
      assert_difference('Resume.count') do
        post :create, params: { resume: { file: file } }
      end
    end
  end

  test 'should create a new resume (even if filename has spaces)' do
    file = fixture_file_upload('resume spacey filename.pdf', 'application/pdf')
    assert_difference('Resume.count') do
      post :create, params: { resume: { file: file } }
    end
  end

  test 'should create a new resume (even if filename has apostrophe)' do
    file = fixture_file_upload("resume o'marr.pdf", 'application/pdf')
    assert_difference('Resume.count') do
      post :create, params: { resume: { file: file } }
    end
  end

  test 'should create a new resume (even if filename has quotes)' do
    file = fixture_file_upload('resume "quoted".pdf', 'application/pdf')
    assert_difference('Resume.count') do
      post :create, params: { resume: { file: file } }
    end
  end

  test 'should not create a new resume if its not a pdf' do
    file = fixture_file_upload('resume.notpdf', 'text/html')
    assert_no_difference('Resume.count') do
      post :create, params: { resume: { file: file } }
    end
    assert_response(400)
  end

  test 'should not create a new resume if nothing is attached' do
    file = nil
    assert_no_difference('Resume.count') do
      post :create, params: { resume: { file: file } }
    end
    assert_response(400)
  end

  test 'should NOT allow anyone not logged in to view an unsubmitted resume' do
    resume = Resume.create(file: File.new('test/fixtures/resume.pdf', 'r'))
    get :show, params: { id: resume.id }
    assert_response(403)
  end

  test 'should not allow anyone not logged in to view a submitted resume' do
    prospect = prospects(:all_valid)
    prospect.build_resume(file: File.new('test/fixtures/resume.pdf', 'r'))
    prospect.save

    get :show, params: { id: prospect.resume_id }
    assert_response(403)
  end

  test 'should allow authed users to view any resume' do
    prospect = prospects(:all_valid)
    prospect.build_resume(file: File.new('test/fixtures/resume.pdf', 'r'))
    prospect.save

    session[:cas] = { user: 'admin' }
    get :show, params: { id: prospect.resume_id }
    assert_response :success

    resume = Resume.create(file: File.new('test/fixtures/resume.pdf', 'r'))
    get :show, params: { id: resume.id }
    assert_response :success
  end
end
