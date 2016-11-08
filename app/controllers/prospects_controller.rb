class ProspectsController < ApplicationController
  before_action :set_session_and_prospect, only: [:new, :create]

  def new
    @prospect.current_step = session[:prospect_step] || Prospect.steps.first
  end

  def create
    @prospect.current_step = session[:prospect_step] || Prospect.steps.first
    choose_action if @prospect.valid?
    if @prospect.new_record?
      render 'new'
    else
      session[:prospect_step] = session[:prospect_params] = nil
      flash[:notice] = 'Saved!'
      redirect_to @prospect
    end
  end

  def show
  end

  def index
    redirect_to action: 'new'
  end

  private

    def prospect_from_session
      Prospect.new(ActionController::Parameters.new(session[:prospect_params]).permit!)
    rescue
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
      session[:prospect_params].each { |k,v| session[:prospect_params][k] = v.to_hash if v.is_a?(ActionController::Parameters) } 
      @prospect = prospect_from_session
    end

    def prospect_params
      # this is just a sanity check since sometimes we don't actually have
      # anything to add when using the back button. If we don't have a prospect
      # param, we just go to the step in session. if we don't have a session,
      # we just go to first step.
      params[:prospect] ||= { current_step: (session[:prospect_step] || Prospect.steps.first) }
      whitelisted_attrs = %i( current_step commit has_family_member in_federal_study directory_id first_name last_name local_address
                              local_phone perm_address perm_phone email family_member class_status
                              graduation_year additional_comments )
      whitelisted_attrs << { day_times: [],
                             skill_ids: [], skills: [:id, :name, :_destroy],
                             work_experiences: [:id, :name, :_destroy] }
      params.require(:prospect).permit(*whitelisted_attrs).tap do |wl|
        wl[:addresses_attributes] = params[:prospect][:addresses_attributes] unless params[:prospect][:addresses_attributes].blank?
        wl[:permanent_address] = params[:prospect][:permanent_address] unless params[:prospect][:permanent_address].blank?
        wl[:work_experiences_attributes] = params[:prospect][:work_experiences_attributes] unless params[:prospect][:work_experiences_attributes].blank?
        wl[:available_times_attributes] = params[:prospect][:available_times_attributes] unless params[:prospect][:available_times_attributes].blank?
        wl[:skills_attributes] = params[:prospect][:skills_attributes] unless params[:prospect][:skills_attributes].blank?
      end
    end

    def whitelisted_attrs
      whitelisted_attrs = %i(
        current_step commit has_family_member in_federal_study directory_id first_name last_name
        local_address local_phone perm_address perm_phone email family_member class_status
        graduation_year additional_comments
      )
      whitelisted_attrs << { skill_ids: [], skills: [:id, :name, :_destroy], work_experiences: [:id, :name, :_destroy] }
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
