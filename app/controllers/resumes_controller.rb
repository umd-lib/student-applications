class ResumesController < ApplicationController
  def create
    @resume = Resume.new(resume_params)
    if @resume.save
      render json: @resume.to_json
    else
      render json: @resume.errors
    end
  end

  def show
    @resume = Resume.includes(:prospect).find(params[:id])
    if @resume.prospect # we only send unsubmitted resumes
      render(text: 'forbidden', status: 403, layout: false)
    else
      send_file(@resume.file.path, disposition: 'attachment', filename: @resume.file_file_name)
    end
  end

  def update
    @resume = Resume.includes(:prospect).find(params[:id])
    if @resume.update(resume_params)
      render json: @resume.to_json
    else
      render json: @resume.errors
    end
  end

  private

    def resume_params
      params.require(:resume).permit(:file)
    end
end
