class ResumesController < ApplicationController
  def create
    @resume = Resume.new(resume_params)
    if @resume.save
      render json: @resume.to_json
    else
      render json: @resume.errors, status: :bad_request
    end
  end

  def show
    @resume = Resume.includes(:prospect).find(params[:id])

    # only allow access to unsubmited resumes
    # if a user if logged in, they can see if.
    if @resume.prospect.nil? || logged_in?
      send_file @resume.file.path, disposition: 'attachment', filename: @resume.file_file_name
    else
      render text: 'forbidden', status: 403, layout: false
    end
  end

  def edit
    render text: 'forbidden', status: 403, layout: false unless logged_in?
    @resume = Resume.includes(:prospect).find(params[:id])
  end

  def update
    @resume = Resume.includes(:prospect).find(params[:id])
    if @resume.update(resume_params)
      render json: @resume.to_json
    else
      render json: @resume.errors, status: :bad_request
    end
  end

  private

    def resume_params
      params.require(:resume).permit(:file)
    end
end
