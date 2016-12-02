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
    if session[:cas].nil? || session[:cas][:user].nil?
      render status: 401, text: 'Redirecting to SSO...'
    end
  end
end
