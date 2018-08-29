class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :fix_cas_session

  rescue_from ActionController::InvalidAuthenticityToken do |_e|
    reset_session
    redirect_to root_url, flash: { notice: 'Application has been reset due to session inactivity.' }
  end

  # rubocop:disable Style/GuardClause
  def fix_cas_session
    if session[:cas] && !session[:cas].is_a?(HashWithIndifferentAccess)
      session[:cas] = session[:cas].with_indifferent_access
    end
  end
  # rubocop:enable Style/GuardClause

  # just returns tue if the user is logged in. does not redirect
  # if not logged in
  def logged_in?
    return false if session[:cas].nil? || session[:cas][:user].nil?
    User.exists?(cas_directory_id: session[:cas][:user])
  end

  # this logs the user in.
  def ensure_auth # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    if session[:prospect_params]
      # we have an application going so we've probably just refreshed the
      # screen
      redirect_to action: 'new', controller: 'prospects'
    elsif session[:cas].nil? || session[:cas][:user].nil?
      render status: 401, text: 'Redirecting to SSO...'
    else
      user = User.find_by cas_directory_id: session[:cas][:user]
      if user.nil?
        render status: 403, text: 'Unrecognized user'
      else
        update_current_user(user)
      end
    end
    nil
  end

  # rubocop:disable Style/GuardClause
  def ensure_admin
    unless @current_user.admin?
      flash[:alert] = 'Access Denied'
      redirect_to root_url
    end
  end
  # rubocop:enable Style/GuardClause

  private

    attr_writer :current_user
    def update_current_user(user)
      @current_user = user
      @current_user.admin = false if session[:disable_admin]
      @current_user
    end
end
