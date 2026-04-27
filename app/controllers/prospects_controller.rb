# frozen_string_literal: true

class ProspectsController < ApplicationController # rubocop:disable Metrics/ClassLength
  include ProspectParameterHandling

  @error_message = "We're sorry, but something has gone wrong. Please try again."

  before_action :set_session, only: %i[new create]
  before_action :set_prospect, only: %i[new create]

  def new
    choose_action if params[:step]
  end

  def create # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
    if params[:reset]
      redirect_to reset_url
    else
      @prospect.current_step = session[:prospect_step] || Prospect.steps.first
      begin
        if @prospect.valid? || params[:back_button]
          choose_action
          if @prospect&.new_record?
            # Got here via POST, and still working on application, so do a GET
            # request so that a browser will not re-POST (and switch pages)
            # on a browser refresh (Post/Redirect/Get (PRG) pattern).
            # This emulates old Rails 6.x TurboLinks behavior
            redirect_to new_prospect_path and return
          end
        end
      rescue ActiveRecord::ActiveRecordError
        flash[:error] = "We're sorry, but something has gone wrong. Please try again."
        @prospect = nil
        redirect_to reset_url
      end
    end

    if @prospect&.new_record?
      render "new"
    elsif @prospect
      begin
        SubmittedMailer.default_email(@prospect).deliver_later
      rescue EOFError, # rubocop:disable Lint/ShadowedException
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

        log_exception(e, @prospect)
      end

      reset_session
      flash[:notice] = "Submitted!"
      redirect_to action: "thank_you", id: @prospect.id

    end
  end

  def thank_you
    @prospect = Prospect.find(params[:id])
  end


  private

    def start_new
      reset_session
      @prospect = Prospect.new
      @prospect.current_step = Prospect.steps.first
    end

    def prospect_from_session
      Prospect.new(ActionController::Parameters.new(session[:prospect_params]).permit!)
    rescue StandardError
      # a nice place to debug..
      # byebug
      reset_session
      redirect_to root_path, flash: { error: @error_message }
    end

    # match the value stored in the session with the incoming values in the
    # param
    def set_session # rubocop:disable Metrics/AbcSize
      session[:prospect_params] ||= {}.with_indifferent_access
      session[:prospect_params].deep_merge!(prospect_params)
      session[:prospect_params].keys.grep(/_attributes$/).each do |attr|
        session[:prospect_params][attr] = params[:prospect][attr] if params[:prospect][attr].present?
      end
      session[:prospect_params].each do |k, v|
        if v.is_a?(ActionController::Parameters)
          session[:prospect_params][k] = convert_attributes_param_to_safe_hash(k, v)
        end
      end
    end

    def set_prospect
      @prospect = Prospect.new(ActionController::Parameters.new(session[:prospect_params]).permit!)
      if @prospect.nil? || !@prospect.is_a?(Prospect)
        reset_session
        redirect_to(root_path, flash: { error: @error_message }) && raise(false)
      else
        @resume = @prospect.resume || @prospect.build_resume
      end
    end

    # decide which step to move to depending on which button was clicked and which step we are already on
    def choose_action # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
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
    rescue ActiveRecord::ActiveRecordError => e
      log_exception(e, @prospect)
      raise e
    end
end
