# frozen_string_literal: true

module Admin
  class ProspectsController < Admin::BaseController # rubocop:disable Metrics/ClassLength
    include ProspectParameterHandling, QueryingProspects

    @error_message = "We're sorry, but something has gone wrong. Please try again."

    def show
      @prospect = Prospect.find(params[:id])
      @resume = @prospect.resume
    end

    def index
      default_search_params
      find_prospects
      @weekdays = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]
    end

    def edit
      @prospect = Prospect.find(params[:id])
      @resume = @prospect.resume
    end

    def update # rubocop:disable Metrics/AbcSize
      @prospect = Prospect.includes(:enumerations, :available_times, :skills).find(params[:id])
      if @prospect.update(prospect_params)
        redirect_to admin_prospects_path, notice: "#{@prospect.name} application has been updated"
      else
        respond_to do |format|
          format.html { redirect_to edit_admin_prospect_path(@prospect), flash: { errors: @prospect.errors } }
          format.json { render json: { errors: @prospect.errors } }
        end
      end
    end

    # we don't actually want to destroy record, but just mark them as inactive
    # accepts a hash of params
    def deactivate
      ids = params[:ids]
      Prospect.where(id: ids).update_all(suppressed: true, updated_at: DateTime.now)
      respond_to do |format|
        format.html { redirect_to admin_prospects_path, flash: { info: "Prospects ( #{ids.join(',')} ) deactivated." } }
        format.json { head :no_content }
      end
    end

    private

      def find_prospects # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        @all_results = Prospect.joins(join_table).select(select_statement)
                              .where(text_search_statement)
                              .where(search_statement)
                              .where(*available_range_statement)
                              .where(prospects_by_available_time)
                              .active.order(sort_order)
                              .pluck("prospects.id").uniq

        # In the following, we run additional queries for the fields that can
        # be filtered, then intersect the results with the results from the
        # overall query. This has the effect of acting as an "OR" within
        # a field, but as an "AND" between fields.
        %w[semesters class_statuses libraries].each do |enum_type|
          where_statement = enumeration_type_search_statement(enum_type)
          next if where_statement.nil?

          type_results = Prospect.joins(join_table).select(select_statement)
                                .where(where_statement)
                                .active.order(sort_order)
                                .pluck("prospects.id").uniq
          @all_results &= type_results
        end

        @per_page = params[:per_page] ? params[:per_page].to_i : 50
        @prospect_ids = @all_results.paginate(page: params[:page], per_page: @per_page)
        @prospects = Prospect.includes(:enumerations, :available_times, :skills).find(@prospect_ids)
                            .index_by(&:id)
                            .values_at(*@prospect_ids)
      end
  end
end
