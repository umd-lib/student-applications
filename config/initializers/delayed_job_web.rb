require 'delayed_job_web'

class DelayedJobWeb < Sinatra::Base
  
	def logged_in_and_admin?
    return false if session[:cas].nil? || session[:cas][:user].nil?
    user = User.find_by(cas_directory_id: session[:cas][:user])
    return ( user && user.admin? ) 
  end

	before do 
		if logged_in_and_admin? 
			return true	
		end
		halt "Unauthorized"		
	end

end
