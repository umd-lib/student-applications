class Enumeration < ActiveRecord::Base
  has_and_belongs_to_many :prospects, join_table: 'prospects_enumerations'

  ENUMERATION_LISTS = %w(class_status graduation_year library semester how_did_you_hear_about_us).map(&:intern).freeze

  enum list: ENUMERATION_LISTS

  class << self
    ENUMERATION_LISTS.map(&:to_s).each do |list|
      define_method(:"active_#{list.pluralize}") do
        where(list: lists[list], active: true)
      end

      define_method(:"#{list.pluralize}") do
        where(list: lists[list])
      end

      define_method(:"#{list}_values") do
        where(list: lists[list]).select(:value)
      end
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
