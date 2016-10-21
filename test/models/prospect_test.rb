require 'test_helper'


class ProspectTest < ActiveSupport::TestCase

  def setup
    @contact_info = prospects(:contact_info)
    @all_valid = prospects(:all_valid)
  end

  test 'should be valid if the contact info is completed on the contact_info step' do
    assert @contact_info.current_step == "contact_info" 
    assert @contact_info.valid?
  end
  
  test 'should be invalid on the contact_info step if the contact info is not present' do
    prospect = Prospect.new
    assert_equal prospect.current_step, "contact_info" 
    refute prospect.valid?
  end
  
  test 'should be valid on a non-contact_info step if the contact info is not present' do
    prospect = Prospect.new
    prospect.next_step
    refute_equal prospect.current_step, "contact_info" 
    assert prospect.valid?
    prospect.previous_step
    refute prospect.valid?
  end

  test "should be all valid if the information is all present" do
    assert @all_valid.all_valid?
  end
  
  test "should not be all valid if the information is not all present" do
    refute Prospect.new.all_valid?
  end

end
