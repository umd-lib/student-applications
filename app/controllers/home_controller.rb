# frozen_string_literal: true

class HomeController < ApplicationController
  def index; end

  def new
    reset_session
    redirect_to new_prospect_path
  end

  def reset
    reset_session
    redirect_to root_url, flash: { notice: 'Application has been reset.' }
  end

  def sign_out
    reset_session if @current_user # just a sanity check..
    redirect_to root_url, flash: { notice: 'Signed out of the application. For security reasons, exit your web browser.' }
  end
end
