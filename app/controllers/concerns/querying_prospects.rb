# concerns for searching for prospects
module QueryingProspects
  extend ActiveSupport::Concern
  included do
    helper_method :sort_column, :sort_direction
  end

  # this is pretty hacky. would be nice to refactor with arel.
  def sort_order # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    col = sort_column
    # do a case-insensitive sort if we are sort on last name
    col = "lower(#{col})" if col.include?('last_name')
    return "#{col} #{sort_direction}" unless col.include?('enumerations')
    klass, method = col.split('.')
    values = klass.singularize.capitalize.constantize.send(method.intern).order("value #{sort_direction} ")
                  .pluck('value')
    order_query = values.each_with_index.inject('CASE ') do |memo, (val, i)|
      memo << "WHEN( enumerations.value = '#{val}') THEN #{i} "
      memo
    end
    "#{order_query} ELSE #{values.length} END"
  end

  private

    def default_search_params
      params[:text_search] ||= {}
      params[:search] ||= {}
      %i[prospect enumerations skills].each do |k|
        params[:search][k] ||= []
      end
    end

    def join_table # rubocop:disable Metrics/AbcSize
      join_tables = []
      if Prospect.reflections.keys.include?(sort_column.split('.').first)
        join_tables << sort_column.split('.').first.intern
      end
      params[:search].each do |key, v|
        next if v.empty?
        join_tables << key if Prospect.reflections.keys.include?(key)
      end
      join_tables.map(&:intern)
    end

    def select_statement
      if sort_column.include?('enumerations')
        'DISTINCT prospects.id, enumerations.value'
      else
        "DISTINCT prospects.id, #{sort_column}"
      end
    end

    def sort_column
      legal_sort_columns = %w[
        prospects.last_name prospects.id prospects.in_federal_study
        enumerations.class_status_values enumerations.semester_values prospects.hired
        enumerations.graduation_year_values prospects.available_hours_per_week
      ]
      legal_sort_columns.include?(params[:sort]) ? params[:sort] : 'prospects.last_name'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    end

    def available_range_statement
      [
        'available_hours_per_week >= ? AND available_hours_per_week <= ?',
        params[:available_hours_per_week_min] || 0,
        params[:available_hours_per_week_max] || 999
      ]
    end

    def text_search_statement
      params_as_hash = params.permit(whitelisted_attrs).to_h
      text_search_params = params_as_hash[:text_search] || {}

      query = text_search_params.each_with_object([]) do |(k, val), memo|
        unless val.empty?
          memo << Prospect.arel_table[k.intern].matches("#{val}%")
        end
      end
      query.present? ? query.inject(&:and) : {}
    end

    def day_times_sql
      dt_params = (params[:available_time] || []).select { |dt| dt.include? '-' }
      dt_values = dt_params.map do |dt|
        dt.split('-').map(&:to_i)
      end
      sql = Array.new(dt_params.size)
                 .fill('SELECT prospect_id FROM available_times WHERE day = ? AND time = ?')
                 .join(' INTERSECT ')
      [sql, *dt_values.flatten]
    end

    def prospects_by_available_time
      params[:available_time] ? { 'prospects.id' => AvailableTime.find_by_sql(day_times_sql).map(&:prospect_id) } : {}
    end

    # Returns a query for the given enumeration type (as represented by the
    # method name on the Enumeration object)
    def enumeration_type_search_statement(enumeration_type)
      all_type_ids = Enumeration.send(enumeration_type).map { |s| s.id.to_s }

      # Get the ids in the params that are in the enumeration type
      ids_for_search = all_type_ids & params[:search][:enumerations]

      return if ids_for_search.empty?
      table_name = Prospect.reflect_on_association('enumerations').table_name
      table_class = table_name.classify.constantize
      arel = table_class.arel_table

      arel[:id].in(ids_for_search)
    end

    def search_statement
      params_as_hash = params.permit(whitelisted_attrs).to_h
      search_params = params_as_hash[:search] || {}

      query = search_params.each_with_object([]) do |(k, val), memo|
        next if val.empty?
        # not sure we really need to reflect on associations but just in case we
        # make some weird data model change
        table_name = Prospect.reflect_on_association(k.intern).table_name
        table_class = table_name.classify.constantize
        arel = table_class.arel_table

        memo << arel[:id].in(Array.wrap(val))
      end
      query.present? ? query.inject(&:and) : {}
    end
end
