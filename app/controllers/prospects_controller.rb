class ProspectsController < ApplicationController
  include QueryingProspects

  @error_message = "We're sorry, but something has gone wrong. Please try again."

  before_action :set_session, only: [:new, :create]
  before_action :set_prospect, only: [:new, :create]
  before_action :ensure_auth, only: [:index, :update, :show, :deactivate]

  def new
    choose_action if params[:step]
  end

  def create
    if params[:reset]
      redirect_to reset_url 
    else
      @prospect.current_step = session[:prospect_step] || Prospect.steps.first
      begin 
        choose_action if @prospect.valid? || params[:back_button]
      rescue ActiveRecord::ActiveRecordError 
        flash[:error] = "We're sorry, but something has gone wrong. Please try again."
        @prospect = nil
        redirect_to reset_url
      end
    end

    if @prospect && @prospect.new_record? 
      render 'new'
    elsif @prospect
      begin 
        SubmittedMailer.default_email(@prospect).deliver_now
     	rescue  EOFError,
							IOError,
							TimeoutError,
							Errno::ECONNRESET,
							Errno::ECONNABORTED,
							Errno::EPIPE,
							Errno::ETIMEDOUT,
							Net::SMTPAuthenticationError,
							Net::SMTPServerBusy,
							Net::SMTPSyntaxError,
							Net::SMTPUnknownError,
            	OpenSSL::SSL::SSLError => e 
					
						log_exception( e, @prospect )					
				end        
        
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
    default_search_params
    find_prospects
    @weekdays = %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)
  end

  def edit
    @prospect = Prospect.find(params[:id])
    @resume = @prospect.resume
  end

  # rubocop:disable Style/GuardClause
  def update
    @prospect = Prospect.includes(:enumerations, :available_times, :skills).find(params[:id])
    if @prospect.update(prospect_params) 
      redirect_to prospects_path, notice: "#{@prospect.name} application has been updated"
    else
      respond_to do |format|
        format.html { redirect_to edit_prospect_path(@prospect), flash: { errors: @prospect.errors } }
        format.json { render json: { errors: @prospect.errors } }
      end
    end
  end
  # rubocop:enable Style/GuardClause

  # we don't actually want to destroy record, but just mark them as inactive
  # accepts a hash of params
  def deactivate
    ids = params[:ids]
    Prospect.where(id: ids).update_all(suppressed: true)
    respond_to do |format|
      format.html { redirect_to prospects_path, flash: { info: "Prospects ( #{ids.join(',')} ) deactivated." } }
      format.json { head :no_content }
    end
  end

  private

    def log_exception( exception, prospect = nil)
        logger.error "~" * 100 
        logger.error "Application Submission Failure!"
        logger.error "Prospect: #{prospect.inspect} Errors: #{prospect.errors}" if prospect
        logger.error "#{exception.message}" 
        logger.error "~" * 100
    end


    def start_new
      reset_session
      @prospect = Prospect.new
      @prospect.current_step = Prospect.steps.first
    end

    def prospect_from_session
      Prospect.new(ActionController::Parameters.new(session[:prospect_params]).permit!)
    rescue
      # a nice place to debug..
      # byebug
      reset_session
      redirect_to root_path, flash: { error: @error_message }
    end

    # match the value stored in the session with the incoming values in the
    # param
    def set_session
      session[:prospect_params] ||= {}.with_indifferent_access
      session[:prospect_params].deep_merge!(prospect_params)
      session[:prospect_params].keys.select { |a| a =~ /_attributes$/ }.each do |attr|
        session[:prospect_params][attr] = params[:prospect][attr] unless params[:prospect][attr].blank?
      end
      session[:prospect_params].each do |k, v|
        session[:prospect_params][k] = v.to_hash if v.is_a?(ActionController::Parameters)
      end
    end

    def set_prospect
      @prospect = Prospect.new(ActionController::Parameters.new(session[:prospect_params]).permit!)
      if @prospect.nil? || !@prospect.is_a?(Prospect)
        reset_session
        redirect_to(root_path, flash: { error: @error_message }) && raise(false)
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
        resume_id user_confirmation user_signature class_status hired hr_comments
        suppressed major semester
      )
      # these are has_many relationships that point to other pre-existing records
      has_many_ids = { enumeration_ids: [], day_times: [], skill_ids: [], library_ids: [] }
      # these are has_many relationships that point to newly created records
      # (accepts_nested_attributes )
      attrs << has_many_ids.merge(
        addresses_attributes: sanitize_model_attrs(Address),
        permanent_address_attributes: sanitize_model_attrs(Address),
        local_address_attributes: sanitize_model_attrs(Address),
        phone_numbers_attributes: sanitize_model_attrs(PhoneNumber),
        contact_phone_attributes: sanitize_model_attrs(PhoneNumber),
        work_experiences_attributes: sanitize_model_attrs(WorkExperience),
        available_times_attributes: sanitize_model_attrs(AvailableTime),
        skills_attributes: sanitize_model_attrs(Skill)
      )
    end

    # This takes a model and pops out the prospect_id which is not needed
    def sanitize_model_attrs(model)
      model.column_names.map(&:intern).reject { |k| k == :prospect_id }
    end

    # decide which step to move to depending on which button was clicked and which step we are already on
    def choose_action
      begin  
        if params[:back_button]
          @prospect.previous_step
        elsif params[:step]
          @prospect.current_step = params[:step]
        elsif @prospect.last_step?
          @prospect.save if @prospect.all_valid?
        else
          @prospect.next_step
        end
        session[:prospect_step] = @prospect.current_step
      rescue  ActiveRecord::ActiveRecordError => e
       	log_exception(e, @prospect)
		    raise e	
      end 
    end

    def find_prospects
      @all_results = Prospect.joins(join_table).select(select_statement)
                              .where(text_search_statement)
                              .where(search_statement)
                              .where(*available_range_statement)
                              .where(prospects_by_available_time)
                              .active.order(sort_order)
                              .pluck('prospects.id').uniq
                              
      @prospect_ids = @all_results.paginate(page: params[:page], per_page: 30)
      @prospects = Prospect.includes(:enumerations, :available_times, :skills).find(@prospect_ids)
                           .index_by(&:id)
                           .values_at(*@prospect_ids)
    end
end
