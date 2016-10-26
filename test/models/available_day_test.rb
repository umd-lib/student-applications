require 'test_helper'

# Unit test for the available time model
class AvailableTimeTest < ActiveSupport::TestCase
  test 'it should be valid' do
    assert AvailableTime.new.valid?
  end

  test 'it should allow to create new available times with days passed in' do
    at = AvailableTime.new day: 'monday', time: 0
    assert_equal at.day_time, "1-0"
    at.save
    at.day = "sunday" 
    assert_equal at.day_time, "0-0"
  end

end
