require 'test_helper'


class AvailableTimeTest < ActiveSupport::TestCase
  
  test "it should be valid" do
    assert AvailableTime.new.valid?
  end
 
  test "it should allow to create new available times with days passed in" do
    at = AvailableTime.new days: "monday"
    assert_includes at.days, "monday"
    at.save
    assert_includes at.days, "monday"
    assert_includes at.available_days.map(&:day), "monday"
  end

  test "it should allow for adding days from a init'ed object" do
    at = AvailableTime.new
    at.days = %w( thursday sunday )
    assert_includes at.available_days.map(&:day), "thursday"
    assert_includes at.days, "sunday"
  end
  


end
