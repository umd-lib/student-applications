class ConfigurationController < ApplicationController
  before_action :ensure_auth

  def show
    @enumerations = Enumeration.all.order(:position).group_by(&:list)
  end

  def update
    if params.key?(:_update_positions)
      render json:   Enumeration.update_positions(params[:ids]).map(&:id)
    elsif params.key?(:_toggle_active)
      render json:   Enumeration.update(params[:enumeration_id], active: params[:_toggle_active])
    elsif params.key?(:enumeration)
      render json: Enumeration.create(enumeration_params)
    end
  end

  private

    def enumeration_params
      params.require(:enumeration).permit(:list, :position, :active, :value)
    end
end
