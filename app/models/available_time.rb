# Times of day the applicant is available to work
class AvailableTime < ActiveRecord::Base
  enum day: %i(sunday monday tuesday wednesday thursday friday saturday)

  attr_writer :day_time
  def day_time
    "#{AvailableTime.days[day]}-#{time}"
  end
end
