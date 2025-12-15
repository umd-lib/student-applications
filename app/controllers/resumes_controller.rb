# frozen_string_literal: true

class ResumesController < ApplicationController
  def new
    render plain: "forbidden", status: :forbidden, layout: false unless logged_in?
    @prospect = Prospect.find(params[:prospect])
    @resume = Resume.new(prospect: @prospect)
  end

  def create
    @resume = Resume.new(resume_params.merge(upload_session_id: upload_session_id))

    if @resume.save
      save_prospect if logged_in? && params[:prospect]
      render json: @resume.to_json(except: :upload_session_id)
    else
      render json: @resume.errors, status: :bad_request
    end
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    render json: "file parameter must not be nil or empty", status: :bad_request
  end

  def show
    @resume = Resume.includes(:prospect).find(params[:id])

    # only allow access to unsubmited resumes to same session that uploaded.
    # if a user if logged in, they can see if.
    if same_session? || logged_in?
      attachment_file_path = ActiveStorage::Blob.service.path_for(@resume.file.key)
      send_file(attachment_file_path, disposition: "attachment", filename: @resume.file.attachment.filename.to_s)
    else
      render plain: "forbidden", status: :forbidden, layout: false
    end
  end

  def edit
    render plain: "forbidden", status: :forbidden, layout: false unless logged_in?
    @resume = Resume.includes(:prospect).find(params[:id])
    @prospect = Prospect.find_by(resume: @resume)
  end

  def update
    @resume = Resume.includes(:prospect).find(params[:id])
    if @resume.update(resume_params)
      render json: @resume.to_json(except: :upload_session_id)
    else
      render json: @resume.errors, status: :bad_request
    end
  end

  private

    def resume_params
      params.require(:resume).permit(:file)
    end

    def same_session?
      (@resume.upload_session_id == session.id.to_s) && @resume.upload_session_id.present?
    end

    def save_prospect
      @prospect = Prospect.find(params[:prospect])
      @prospect.resume = @resume
      @prospect.save
    end

    def upload_session_id
      session.id.to_s || SecureRandom.hex(16).encode(Encoding::UTF_8)
    end
end
