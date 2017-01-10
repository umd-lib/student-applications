module QueryingProspects
  extend ActiveSupport::Concern
  included do
    helper_method :sort_column, :sort_direction
  end

  # this is pretty hacky. would be nice to refactor with arel.
  def sort_order
    col = sort_column
    # do a case-insensitive sort if we are sort on last name
    col = "lower(#{col})" if col.include?("last_name")
    return "#{col} #{sort_direction}" unless col.include?("enumerations")
    klass, method = col.split(".")
    values = klass.singularize.capitalize.constantize.send(method.intern).order("value #{ sort_direction  } ").pluck("value")
    order_query = values.each_with_index.inject("CASE ") do |memo,( val,i )|
      memo << "WHEN( enumerations.value = '#{val}') THEN #{i} "
      memo
    end
    "#{order_query} ELSE #{values.length} END"
  end

  private

  def default_search_params
    params[:text_search] ||= {}
    params[:search] ||= { }
    %i( prospect enumerations skills ).each do |k|
      params[:search][k] ||= []
    end
  end

  def join_table
    join_tables = []
    if Prospect.reflections.keys.include?( sort_column.split(".").first  )
      join_tables <<  sort_column.split(".").first.intern
    end
    params[:search].each do |key,v|
      next if v.empty?
      join_tables << key if Prospect.reflections.keys.include?(key)
    end
    join_tables.map(&:intern)
  end

  def select_statement
    if sort_column.include?("enumerations")
      "DISTINCT prospects.id, enumerations.value"
    else
      "DISTINCT prospects.id, #{sort_column}"
    end
  end

  def sort_column
    %w( prospects.last_name prospects.id prospects.in_federal_study
    enumerations.class_status_values enumerations.semester_values prospects.hired
       enumerations.graduation_year_values prospects.available_hours_per_week
      ).include?(params[:sort]) ? params[:sort] : "prospects.last_name"
  end

  def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

  def available_range_statement
      ["available_hours_per_week >= ? AND available_hours_per_week <= ?",
        params[:available_hours_per_week_min] || 0 ,
        params[:available_hours_per_week_max] || 999 ]
  end

  def text_search_statement
    query = params[:text_search].inject([]) do |memo, (k,val ) |
      unless  val.empty?
        memo << Prospect.arel_table[k.intern].matches( "#{val}%" )
      end
      memo
    end
    !query.blank? ? query.inject(&:and) : {}
  end

  def search_statement
    query = params[:search].inject([]) do |memo, ( k,val ) |
      unless val.empty?
	      # not sure we really need to reflect on associations but just in case we
	      # make some weird data model change
	      memo << Arel::Table.new( Prospect.reflect_on_association(k.intern).table_name )[:id].in( Array.wrap( val ) )
      end
      memo
    end
    !query.blank? ? query.inject(&:and) : {}
  end

end
