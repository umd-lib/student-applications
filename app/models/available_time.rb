# Times of day the applicant is available to work
class AvailableTime < ActiveRecord::Base
  has_many :available_days
  accepts_nested_attributes_for :available_days, allow_destroy: true

  # keeps rails from freaking out.
  attr_accessor :days

  def initialize(attributes = nil, options = {})
    unless attributes.nil? || attributes[:days].blank?
      days = Array.wrap(attributes[:days]).flatten.reject(&:blank?)
    end
    super
  end

  # This allows us to create available days by passing in the day name to the
  # object
  def days=(names = [])
    names = Array.wrap(names)
    names.flatten!
    names.reject!(&:blank?)

    day_attrs = []
    # if there's a day not in out map, we mark it for delete
    day_attrs << available_days.map { |ad| { id: ad.id, "_destroy": 1 } unless names.include?(ad.day) }

    ## now any incoming days that are not already in the db
    # first we mark all available days for delete
    current_days = available_days.map(&:day)
    day_attrs << names.map { |n| { day: n } unless current_days.include?(n) }

    # now set the attributes. note these changes won't take effect until #save is
    # called.
    day_attrs.flatten!
    day_attrs.reject!(&:blank?)
    self.available_days_attributes = day_attrs
    days
  end

  # returns available_days as a list of day names
  def days
    Array.wrap(available_days.map(&:day)).compact
  end
end
