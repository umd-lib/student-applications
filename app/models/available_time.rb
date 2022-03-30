# frozen_string_literal: true

# Times of day the applicant is available to work
class AvailableTime < ApplicationRecord
  belongs_to :prospect, counter_cache: true
  enum day: { sunday: 0, monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6 }

  attr_writer :day_time

  def day_time
    "#{AvailableTime.days[day]}-#{time}"
  end
end
