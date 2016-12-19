class Enumeration < ActiveRecord::Base
  has_and_belongs_to_many :prospects, join_table: 'prospects_enumerations'

  enum list: %i(class_status graduation_year library semester)

  class << self
    def active_class_statuses
      where(list: lists['class_status'], active: true)
    end

    def active_graduation_years
      where(list: lists['graduation_year'], active: true)
    end

    def active_libraries
      where(list: lists['library'], active: true)
    end

    def active_semesters
      where(list: lists['semester'], active: true)
    end

    # this takes an array of key values and updates the positions based on
    # their position in the array.
    def update_positions(ids)
      positions = *(0..ids.length).each_with_object([]) { |v, m| m << { position: v }; m }
      Enumeration.update(ids, positions)
    end
  end

  def to_s
    value
  end
end
