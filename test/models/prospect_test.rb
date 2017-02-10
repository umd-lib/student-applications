require 'test_helper'

# Unit test for the prospect (i.e., application form) model
class ProspectTest < ActiveSupport::TestCase
  def setup
    @contact_info = prospects(:contact_info)
    @all_valid = prospects(:all_valid)
  end


  test 'should be valid if the contact info is completed on the contact_info step' do
    assert @contact_info.current_step == Prospect.first_step
    @contact_info.next_step
    assert @contact_info.current_step == 'contact_info'
    assert @contact_info.valid?
  end

  test 'should be invalid on the contact_info step if the contact info is not present' do
    prospect = Prospect.new( directory_id: "123", semester: Enumeration.active_semesters.first.value  )
    prospect.next_step
    assert_equal prospect.current_step, 'contact_info'
    refute prospect.valid?
  end

  test 'should be valid on a non-contact_info step if the contact info is not present' do
    prospect = Prospect.new
    prospect.next_step
    prospect.next_step
    refute_equal prospect.current_step, 'contact_info'
    assert prospect.valid?
    prospect.previous_step
    refute prospect.valid?
  end

  test 'should be all valid if the information is all present' do
    assert @all_valid.all_valid?
  end

  test 'should not be all valid if the information is not all present' do
    refute Prospect.new.all_valid?
  end

  test 'should create a local_address on init' do
    prospect = Prospect.new
    assert prospect.addresses.length == 1
    assert_includes prospect.addresses, prospect.local_address
  end

  test 'should keep the local address if created with one' do
    prospect = Prospect.new(addresses: [Address.new(address_type: 'local', street_address_1: '666 Lovers Ln')])
    assert_equal prospect.addresses.length, 1
    assert_equal prospect.addresses.first.street_address_1, prospect.local_address.street_address_1
  end

  test "it should be invalid if it's on the contact_info step and it has no address" do
    homeless = prospects(:homeless)
    homeless.next_step
    homeless.contact_phone.phone_type = 'local'
    homeless.contact_phone.number = '301-555-0123'
    # not valid bc no address
    refute homeless.valid?
    # but if we ae on another step, it should be ok
    homeless.next_step
    assert homeless.valid?

    homeless.previous_step
    %i(street_address_1= city= state= postal_code=).each do |attr|
      homeless.local_address.send(attr, SecureRandom.hex)
    end
    assert homeless.valid?, homeless.errors
  end

  test 'should create a contact_phone on init' do
    prospect = Prospect.new
    assert prospect.phone_numbers.length == 1
    assert_includes prospect.phone_numbers, prospect.contact_phone
  end

  test 'should keep the contact phone if created with one' do
    prospect = Prospect.new(phone_numbers: [PhoneNumber.new(phone_type: 'local', number: '301-555-0123')])
    assert_equal prospect.phone_numbers.length, 1
    assert_equal prospect.phone_numbers.first.number, prospect.contact_phone.number
  end

  test 'it should be able to create available_times via the day_times shortcut' do
    prospect = Prospect.new day_times: ['0-0', '4-20', '0-12']
    assert_equal prospect.available_times.length, prospect.day_times.length
    prospect.available_times.each do |a|
      assert_includes prospect.day_times, a.day_time
    end
  end
  
  test 'it should be able to modify available_times via the day_times shortcut' do
    prospect = prospects(:all_valid) 
    dts = prospect.day_times
    assert_equal prospect.available_times.length, dts.length
    new_dts=  [ "0-13", "1-14", "2-15", "3-16", "4-17", "5-18", "6-19" ] 
    prospect.day_times = new_dts 
    assert prospect.save!
    assert_equal prospect.day_times, new_dts
  end

  test 'it ensure the total available hours is not more than the available_times selected' do
    assert_equal @all_valid.available_hours_per_week, 1
    @all_valid.available_hours_per_week = 100
    refute @all_valid.valid?
    @all_valid.available_hours_per_week = @all_valid.available_times.size
    assert @all_valid.valid?
  end

  test 'it can get a prospected special / unpromoted skills' do
    prospect = Prospect.new
    prospect.skills << Skill.new(name: 'typin', promoted: true)
    prospect.skills << Skill.new(name: 'fightin', promoted: false)
    assert_equal prospect.skills.length, 2
    assert_equal prospect.special_skills.length, 1
    assert_equal prospect.special_skills.first.name, 'fightin'
  end
  
  test 'it can set the semester' do
    prospect = Prospect.new
    
    values = Enumeration.active_semesters

    prospect.semester = values.first.value

    assert_includes prospect.enumerations, values.first 
    
    prospect.semester = values.last.value
    refute_includes prospect.enumerations, values.first 
    assert_includes prospect.enumerations, values.last

  end
end
