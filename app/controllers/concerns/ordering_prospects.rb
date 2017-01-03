module OrderingProspects
  extend ActiveSupport::Concern
  included do 
    helper_method :sort_column, :sort_direction
  end

  def sort_order
    col = sort_column 
    return "#{col} #{sort_direction}" unless col.include?("enumerations")
    klass, method = col.split(".")
    values = klass.singularize.capitalize.constantize.send(method.intern).order("value #{ sort_direction  } ").pluck("value")
    order_query = values.each_with_index.inject("CASE ") do |memo,( val,i )|
      memo << "WHEN  'enumerations'.'value' = '#{val}' THEN #{i} "
      memo
    end
    "#{order_query} ELSE #{values.length} END" 
  end

  private
    
  def join_table
    Prospect.reflections.keys.include?( sort_column.split(".").first  ) ? [ sort_column.split(".").first.intern ] : []
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


end
