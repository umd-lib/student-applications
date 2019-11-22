# frozen_string_literal: true

# Times of day the applicant is available to work
class AvailableTime < ApplicationRecord
  belongs_to :prospect, counter_cache: true
  enum day: %i[sunday monday tuesday wednesday thursday friday saturday]

  attr_writer :day_time
  def day_time
    "#{AvailableTime.days[day]}-#{time}"
  end
end
