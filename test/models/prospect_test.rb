require 'test_helper'

# Unit test for the prospect (i.e., application form) model
class ProspectTest < ActiveSupport::TestCase
  def setup
    @contact_info = prospects(:contact_info)
    @all_valid = prospects(:all_valid)
  end

  test 'should be valid if the contact info is completed on the contact_info step' do
    assert @contact_info.current_step == 'contact_info'
    assert @contact_info.valid?
  end

  test 'should be invalid on the contact_info step if the contact info is not present' do
    prospect = Prospect.new
    assert_equal prospect.current_step, 'contact_info'
    refute prospect.valid?
  end

  test 'should be valid on a non-contact_info step if the contact info is not present' do
    prospect = Prospect.new
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
    prospect = Prospect.new(addresses: [Address.new(street_address_1: '666 Lovers Ln')])
    assert_equal prospect.addresses.length, 1
    assert_equal prospect.addresses.first.street_address_1, prospect.local_address.street_address_1
  end

  test 'it should set the family_member attr correct and only validate if the name is provided' do
    [true, 'true', 1].each do |truthy|
      prospect = Prospect.new @all_valid.attributes.merge(has_family_member: truthy)
      refute prospect.valid?
      prospect.family_member = 'Stehpen Colbert'
      assert prospect.valid?
    end
  end

  test "it should also know if there's a family member if a family member name has been provided" do
    prospect = Prospect.new @all_valid.attributes.merge(family_member: 'Jon Stewart')
    assert prospect.family_member?
    assert prospect.has_family_member

    # if the attr is set to false but a name has been provided, thats ok, but
    # the family_member? should still return true for validation.
    prospect = Prospect.new @all_valid.attributes.merge(family_member: "Conan O'Brien", has_family_member: false)
    assert prospect.family_member?
    refute prospect.has_family_member
  end

  test "it should be invalid if it's on the contact_info step and it has no address" do
    homeless = prospects(:homeless)
    # not valid bc no address
    refute homeless.valid?
    # but if we ae on another step, it should be ok
    homeless.next_step
    assert homeless.valid?

    homeless.previous_step
    %i(street_address_1= city= state= postal_code=).each do |attr|
      homeless.local_address.send(attr, SecureRandom.hex)
    end
    assert homeless.valid?
  end
end
