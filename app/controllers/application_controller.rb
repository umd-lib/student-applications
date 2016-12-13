class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :fix_cas_session

  def fix_cas_session
    if session[:cas] && !session[:cas].is_a?(HashWithIndifferentAccess)
      session[:cas] = session[:cas].with_indifferent_access
    end
  end

  def ensure_auth
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

  private

    attr_writer :current_user
    def update_current_user(user)
      @current_user = user
      @current_user
    end
end
