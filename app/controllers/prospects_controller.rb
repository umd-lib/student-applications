class ProspectsController < ApplicationController
  before_action :set_session_and_prospect, only: [:new, :create]
  before_action :ensure_auth, only: [:index, :update, :show]

  def create
    if params[:reset]
      reset_session
      redirect_to action: "reset" 
    else
      @prospect.current_step = session[:prospect_step] || Prospect.steps.first
      choose_action if @prospect.valid?
    end

    if @prospect.new_record?
      render "new" 
    else
      SubmittedMailer.default_email(@prospect).deliver_now
      reset_session
      flash[:notice] = 'Submitted!'
      redirect_to action: 'thank_you', id: @prospect.id
    end
  end

  def thank_you
    @prospect = Prospect.find(params[:id])
  end

  def show
    @prospect = Prospect.find(params[:id])
    @resume = @prospect.resume
  end

  def index
    @prospects = Prospect.paginate(page: params[:page])
  end

  def update
    @prospect = Prospect.find(params[:id])
    if @prospect.update(prospect_params)
      redirect_to prospect_path(@prospect), notice: 'Your application has been updated'
    end
  end

  private

    def start_new
      reset_session
      @prospect = Prospect.new
      @prospect.current_step = Prospect.steps.first
    end

    def prospect_from_session
      Prospect.new(ActionController::Parameters.new(session[:prospect_params]).permit!)
    rescue => e
      # a nice place to debug..
      # byebug
      reset_session
      redirect_to root_path, flash: { error: "We're sorry, but something has gone wrong. Please try again." }
    end

    # match the value stored in the session with the incoming values in the
    # param
    def set_session_and_prospect
      session[:prospect_params] ||= {}.with_indifferent_access
      session[:prospect_params].deep_merge!(prospect_params)
      session[:prospect_params].keys.select { |a| a =~ /_attributes$/ }.each do |attr|
        session[:prospect_params][attr] = params[:prospect][attr] unless params[:prospect][attr].blank?
      end
      session[:prospect_params].each { |k, v| session[:prospect_params][k] = v.to_hash if v.is_a?(ActionController::Parameters) }
      @prospect = Prospect.new(ActionController::Parameters.new(session[:prospect_params]).permit!)
      if @prospect.nil? || !@prospect.is_a?(Prospect)
        reset_session
        redirect_to(root_path, flash: { error: "We're sorry, but something has gone wrong. Please try again." }) && raise(false)
      else
        @resume = @prospect.resume ? @prospect.resume : @prospect.build_resume
      end
    end

    def prospect_params
      # this is just a sanity check since sometimes we don't actually have
      # anything to add when using the back button. If we don't have a prospect
      # param, we just go to the step in session. if we don't have a session,
      # we just go to first step.
      params[:prospect] ||= { current_step: (session[:prospect_step] || Prospect.steps.first) }
      params[:prospect] = params[:prospect].with_indifferent_access
      params.require(:prospect).permit(*whitelisted_attrs)
    end

    def whitelisted_attrs
      # these are all the single keys that are allowed.
      attrs = %i(
        current_step commit in_federal_study directory_id first_name last_name
        email class_status graduation_year additional_comments available_hours_per_week
        resume_id user_confirmation user_signature class_status
      )
      # these are has_many relationships that point to other pre-existing records
      has_many_ids = { enumeration_ids: [], day_times: [], skill_ids: [], library_ids: [] }
      # these are has_many relationships that point to newly created records
      # (accepts_nested_attributes )
      attrs << has_many_ids.merge(addresses_attributes: sanitize_model_attrs(Address), permanent_address_attributes: sanitize_model_attrs(Address),
                                  local_address_attributes: sanitize_model_attrs(Address), phone_numbers_attributes: sanitize_model_attrs(PhoneNumber),
                                  work_experiences_attributes: sanitize_model_attrs(WorkExperience), available_times_attributes: sanitize_model_attrs(AvailableTime),
                                  skills_attributes: sanitize_model_attrs(Skill))
    end

    # This takes a model and pops out the prospect_id which is not needed
    def sanitize_model_attrs(model)
      model.column_names.map(&:intern).reject { |k| k == :prospect_id }
    end

    # decide which step to move to depending on which button was clicked and which step we are already on
    def choose_action
      if params[:back_button]
        @prospect.previous_step
      elsif params[:goto_contact_info]
        @prospect.current_step = 'contact_info'
      elsif params[:goto_work_experience]
        @prospect.current_step = 'work_experience'
      elsif params[:goto_skills]
        @prospect.current_step = 'skills'
      elsif params[:goto_upload_resume]
        @prospect.current_step = 'upload_resume'
      elsif params[:goto_availability]
        @prospect.current_step = 'availability'
      elsif @prospect.last_step?
        @prospect.save if @prospect.all_valid?
      else
        @prospect.next_step
      end
      session[:prospect_step] = @prospect.current_step
    end
end
