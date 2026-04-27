# frozen_string_literal: true

# Concern for managing Prospect parameter methods that are shared between
# user and admin ProspectsControllers
module ProspectParameterHandling
  extend ActiveSupport::Concern

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
end
