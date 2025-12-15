# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :ensure_auth
  before_action :ensure_admin, except: :disable_admin

  def create
    @user = User.new(user_params)
    respond_to do |format|
      format.json do
        @user.save ? @user.to_json : render(json: { errors: @user.errors, status: :not_acceptable })
      end
      format.html  do
        @user.save ? redirect_to(users_path, notice: "#{@user.name} created") : render(index)
      end
    end
  end

  def index
    @users = User.all
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      render json: @user.to_json
    else
      render json: @user.errors
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: "#{@user.name} deleted." }
      format.json { head :no_content }
    end
  end

  def disable_admin
    session[:disable_admin] = true
    respond_to do |format|
      format.html do
        redirect_to prospects_url,
                    notice: "You have temporarly disabled admin functionality. " \
                            "Sign out and log back in to restore admin role."
      end
    end
  end

  private

    def user_params
      params.require(:user).permit(:cas_directory_id, :name, :admin)
    end
end
