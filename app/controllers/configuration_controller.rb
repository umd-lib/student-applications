class ConfigurationController < ApplicationController
  before_action :ensure_auth
  before_action :ensure_admin

  def show
    @enumerations = Enumeration.order(:position).all.group_by(&:list)
    @skills = Skill.order(promoted: :desc, name: :asc).all.paginate(page: params[:skills_page], per_page: 30)
  end

  # this is where we can update:
  # 1) The positions of enum values in a enum list ( pass in an array
  #   of ids in ordered desired in :update_positions_ids )
  # 2) Toggle Skill promoted boolean ( pass in an id :toggle_promoted_id )
  # 3) Toggle Enumeration active boolean ( pass in id in :toggle_active_id )
  # 4) Create an new enuemration ( in :enumeration param )
  # 5) Create a new skill
  def update # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
    if params.key?(:update_positions_ids) # this just resets the list of enum values
      render json: Enumeration.update_positions(params[:update_positions_ids]).map(&:id)
    elsif params.key?(:toggle_promoted_id)
      render json: Skill.find(params[:toggle_promoted_id]).toggle!(:promoted)
    elsif params.key?(:toggle_active_id)
      render json: Enumeration.find(params[:toggle_active_id]).toggle!(:active)
    elsif params.key?(:enumeration)
      render json: Enumeration.create(enumeration_params)
    elsif params.key?(:skill)
      render json: Skill.create(skill_params)
    end
  rescue ActiveRecord::ActiveRecordError => e
    render json: { error: e.message }, status: :bad_request
  end

  private

    def skill_params
      params.require(:skill).permit(:name, :promoted)
    end

    def enumeration_params
      params.require(:enumeration).permit(:list, :position, :active, :value)
    end
end
