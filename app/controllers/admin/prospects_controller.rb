# frozen_string_literal: true

module Admin
  class ProspectsController < Admin::BaseController # rubocop:disable Metrics/ClassLength
    include QueryingProspects

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
        format.html { redirect_to prospects_path, flash: { info: "Prospects ( #{ids.join(',')} ) deactivated." } }
        format.json { head :no_content }
      end
    end

    private

      def log_exception(exception, prospect = nil)
        logger.error "~" * 100
        logger.error "Application Submission Failure!"
        logger.error "Prospect: #{prospect.inspect} Errors: #{prospect.errors}" if prospect
        logger.error exception.message.to_s
        logger.error "~" * 100
      end

      def prospect_params
        # this is just a sanity check since sometimes we don't actually have
        # anything to add when using the back button. If we don't have a prospect
        # param, we just go to the step in session. if we don't have a session,
        # we just go to first step.
        params[:prospect] ||= { current_step: (session[:prospect_step] || Prospect.steps.first) }
        params.require(:prospect).permit(*whitelisted_attrs)
      end

      # Converts attribute-related params that have multiple instances (and so
      # are listed with numeric keys) into "safe" hash by passing them through
      # whitelisted_attrs
      #
      # attr - The attribute (addresses, phone_numbers, etc.) to use in
      #        passing through whitelisted_attrs
      # param - the ActionController::Parameters object to convert
      def convert_attributes_param_to_safe_hash(attr, param)
        # Get an unsafe hash of the param
        unsafe_hash = param.to_unsafe_h

        # The hash of permitted attributes
        safe_hash = {}

        # Assume that each key ends with "attributes" and corresponds with
        # attributes in the whitelist (addresses_attributes,
        # phone_numbers_attributes, etc.)
        unsafe_hash.each do |(key, value)|
          # Assign the value to a hash using the attribute as a key, instead of
          # index number ("0", "1", etc.)
          temp_hash = { attr => value }
          # Create a new Parameters object
          temp_param = ActionController::Parameters.new(temp_hash)
          # Pass the Parameters object through the whitelist and get the hash
          temp_param_hash = temp_param.permit(whitelisted_attrs).to_hash
          # Merge into safe_hash result, using the original numeric key as the
          # hash key
          safe_hash.merge!(key => temp_param_hash[attr])
        end
        safe_hash
      end

      def whitelisted_attrs # rubocop:disable Metrics/MethodLength
        # these are all the single keys that are allowed.
        attrs = %i[
          current_step commit in_federal_study directory_id first_name last_name
          email class_status graduation_year additional_comments available_hours_per_week
          resume_id user_confirmation user_signature class_status hired hr_comments
          suppressed major semester
        ]
        # these are has_many relationships that point to other pre-existing records
        has_many_ids = { enumeration_ids: [], day_times: [], skill_ids: [], library_ids: [] }
        # these are has_many relationships that point to newly created records
        # (accepts_nested_attributes )
        attrs << has_many_ids.merge(
          addresses_attributes: sanitize_model_attrs(Address),
          permanent_address_attributes: sanitize_model_attrs(Address),
          local_address_attributes: sanitize_model_attrs(Address),
          phone_numbers_attributes: sanitize_model_attrs(PhoneNumber),
          contact_phone_attributes: sanitize_model_attrs(PhoneNumber),
          work_experiences_attributes: sanitize_model_attrs(WorkExperience),
          available_times_attributes: sanitize_model_attrs(AvailableTime),
          skills_attributes: sanitize_model_attrs(Skill)
        )

        # attributes for filtering
        attrs << { search: { prospect: [], enumerations: [], skills: [] } }
        attrs << { text_search: %i[last_name first_name directory_id] }
      end

      # This takes a model and pops out the prospect_id which is not needed
      def sanitize_model_attrs(model)
        model.column_names.map(&:intern).reject { |k| k == :prospect_id }
      end

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
