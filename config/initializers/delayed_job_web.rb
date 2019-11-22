require 'delayed_job_web'

class DelayedJobWeb < Sinatra::Base
  def logged_in_and_admin?
    return false if session[:cas].nil? || session[:cas]['user'].nil?
    user = User.find_by(cas_directory_id: session[:cas]['user'])
    (user && user.admin?)
  end

  before do
    return true if logged_in_and_admin?
    halt 'Unauthorized'
  end
end
