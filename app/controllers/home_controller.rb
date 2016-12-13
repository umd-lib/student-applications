class HomeController < ApplicationController
  def index; end

  def new
    reset_session
    redirect_to new_prospect_path
  end

end
