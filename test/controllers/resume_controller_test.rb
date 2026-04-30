# frozen_string_literal: true

require "test_helper"

class ResumesControllerTest < ActionController::TestCase
  test "should create a new resume" do
    file = fixture_file_upload("resume.pdf", "application/pdf")
    assert_difference("Resume.count") do
      post :create, params: { resume: { file: file } }
    end
  end

  test "should create a new resume ( even if the mime is weird )" do
    %w[application/force-download application/octet-stream application/pdf].each do |mime|
      file = fixture_file_upload("resume.pdf", mime)
      assert_difference("Resume.count") do
        post :create, params: { resume: { file: file } }
      end
    end
  end

  test "should create a new resume (even if filename has spaces)" do
    file = fixture_file_upload("resume spacey filename.pdf", "application/pdf")
    assert_difference("Resume.count") do
      post :create, params: { resume: { file: file } }
    end
  end

  test "should create a new resume (even if filename has apostrophe)" do
    file = fixture_file_upload("resume o'marr.pdf", "application/pdf")
    assert_difference("Resume.count") do
      post :create, params: { resume: { file: file } }
    end
  end

  test "should create a new resume (even if filename has quotes)" do
    file = fixture_file_upload('resume "quoted".pdf', "application/pdf")
    assert_difference("Resume.count") do
      post :create, params: { resume: { file: file } }
    end
  end

  test "should not create a new resume if its not a pdf" do
    file = fixture_file_upload("resume.notpdf", "text/html")
    assert_no_difference("Resume.count") do
      post :create, params: { resume: { file: file } }
    end
    assert_response(400)
  end

  test "should not create a new resume if nothing is attached" do
    file = nil
    assert_no_difference("Resume.count") do
      post :create, params: { resume: { file: file } }
    end
    assert_response(400)
  end

  test "should store the current session id in upload_session_id when creating a resume" do
    post :create, params: { resume: { file: fixture_file_upload("resume.pdf", "application/pdf") } }
    assert_response :success

    resume = Resume.find(JSON.parse(response.body)["id"])

    # Verifies that upload_session_id is populated from session.id on create
    assert resume.upload_session_id.present?, "upload_session_id should not be blank"
    assert_equal @request.session.id.to_s, resume.upload_session_id
  end

  test "should NOT allow anyone not logged in to view an unsubmitted resume" do
    resume = Resume.create(file: { io: File.open("test/fixtures/files/resume.pdf"), filename: "resume.pdf" })
    get :show, params: { id: resume.id }
    assert_response(403)
  end

  test "should not allow anyone not logged in to view a submitted resume" do
    prospect = prospects(:all_valid)
    resume = Resume.new(file: { io: File.open("test/fixtures/files/resume.pdf"), filename: "resume.pdf" })
    prospect.resume = resume
    prospect.save

    get :show, params: { id: prospect.resume_id }
    assert_response(403)
  end

  test "should allow authed users to view any resume" do
    prospect = prospects(:all_valid)
    resume = Resume.new(file: { io: File.open("test/fixtures/files/resume.pdf"), filename: "resume.pdf" })
    prospect.resume = resume
    prospect.save

    session[:cas] = { user: "admin" }
    get :show, params: { id: prospect.resume_id }
    assert_response :success

    resume = Resume.create(file: { io: File.open("test/fixtures/files/resume.pdf"), filename: "resume.pdf" })
    get :show, params: { id: resume.id }
    assert_response :success
  end

  test "should NOT allow an unauthenticated user to update a resume uploaded in a different session" do
    resume = Resume.create!(
      file: { io: File.open("test/fixtures/files/resume.pdf"), filename: "resume.pdf" },
      upload_session_id: "some-other-session-id" # simulates a resume owned by a different browser session
    )

    file = fixture_file_upload("resume spacey filename.pdf", "application/pdf")
    patch :update, params: { id: resume.id, resume: { file: file } }

    assert_response(403)

    # Original file has not been changed
    resume.reload
    assert_equal "resume.pdf", resume.file.filename.to_s
  end

  test "should NOT allow an unauthenticated user with missing upload_session_id to update any resume" do
    resume = Resume.create!(
      file: { io: File.open("test/fixtures/files/resume.pdf"), filename: "resume.pdf" }
      # upload_session_id intentionally left out
    )

    file = fixture_file_upload("resume spacey filename.pdf", "application/pdf")
    patch :update, params: { id: resume.id, resume: { file: file } }

    assert_response(403)

    # Original file has not been changed
    resume.reload
    assert_equal "resume.pdf", resume.file.filename.to_s
  end

  test "should allow a student to update a resume they uploaded in the same session" do
    # POST :create stores session.id in upload_session_id; reuse the same
    # @request session for the subsequent PATCH to satisfy same_session?.
    post :create, params: { resume: { file: fixture_file_upload("resume.pdf", "application/pdf") } }
    assert_response :success

    resume_id = JSON.parse(response.body)["id"]
    resume = Resume.find_by(id: resume_id)
    assert_equal "resume.pdf", resume.file.filename.to_s

    file = fixture_file_upload("resume spacey filename.pdf", "application/pdf")
    patch :update, params: { id: resume_id, resume: { file: file } }

    assert_response :success

    # Resume has been updated
    resume.reload
    assert_equal "resume spacey filename.pdf", resume.file.filename.to_s
  end

  test "should allow a logged-in user to update any resume" do
    resume = Resume.create!(
      file: { io: File.open("test/fixtures/files/resume.pdf"), filename: "resume.pdf" },
      upload_session_id: "some-other-session-id"
    )

    session[:cas] = { user: "admin" }
    file = fixture_file_upload("resume spacey filename.pdf", "application/pdf")
    patch :update, params: { id: resume.id, resume: { file: file } }

    assert_response :success

    # Resume has been updated
    resume.reload
    assert_equal "resume spacey filename.pdf", resume.file.filename.to_s
  end
end
