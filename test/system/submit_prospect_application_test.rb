# frozen_string_literal: true

require 'application_system_test_case'

# Integration test for submitting the application form
class SubmitProspectApplicationTest < ApplicationSystemTestCase
  test 'starting an application' do
    visit '/'
    click_link 'Apply!'
    assert page.has_content?('Please enter your Student ID and Semester You are Applying For')
  end

  test "won't go past directory id and semester information if the values are not present" do
    visit '/'
    click_link 'Apply!'
    assert page.has_content?('Please enter your Student ID and Semester You are Applying For')
    click_button 'Continue'
    assert page.has_content?('Please enter your Student ID and Semester You are Applying For')
    assert page.has_content?("can't be blank")
    assert_equal Prospect.steps.first, page.get_rack_session_key('prospect_params')['current_step']
  end

  test "won't go past contact information if the values are not present" do
    visit '/'
    click_link 'Apply!'

    fill_in('Directory', with: 'myIdentifier')
    choose(Enumeration.active_semesters.first.value)

    click_button 'Continue'
    assert page.has_content?('Contact Information')
    click_button 'Continue'
    assert page.has_content?('Contact Information')
    assert page.has_content?("can't be blank")
    assert_equal Prospect.steps.first, page.get_rack_session_key('prospect_params')['current_step']
  end

  test 'that it can create contact information and proceed to next step' do
    visit '/'
    click_link 'Apply!'

    fill_in('Directory', with: 'myIdentifier')
    choose(Enumeration.active_semesters.first.value)

    click_button 'Continue'

    fill_in('prospect_first_name', with: 'Polly')
    fill_in('prospect_last_name', with: 'Jane')

    fill_in('prospect_addresses_attributes_0_street_address_1', with: '555 Fake St')
    fill_in('prospect_addresses_attributes_0_city', with: 'Springfield')
    fill_in('prospect_addresses_attributes_0_state', with: 'HI')
    fill_in('prospect_addresses_attributes_0_postal_code', with: '12345')

    fill_in('prospect_phone_numbers_attributes_0_number', with: '301-555-0123')
    select('local', from: 'prospect_phone_numbers_attributes_0_phone_type')

    select(Enumeration.active_graduation_years.first.value, from: 'graduation_year')
    select(Enumeration.active_class_statuses.first.value, from: 'class_status')

    fill_in('prospect_email', with: 'pj@umd.edu')
    choose('prospect_in_federal_study_true')

    click_button 'Continue'
    assert page.has_content?('Work Experience')
    assert_equal Prospect.steps[2], page.get_rack_session_key('prospect_step')
  end

  test 'that it can keeps values while proceeding to next step or going back' do
    visit '/'
    click_link 'Apply!'

    fill_in('Directory', with: 'myIdentifier')
    choose(Enumeration.active_semesters.first.value)
    click_button 'Continue'

    fill_in('prospect_first_name', with: 'Polly')
    fill_in('prospect_last_name', with: 'Jane')

    fill_in('prospect_addresses_attributes_0_street_address_1', with: '555 Fake St')
    fill_in('prospect_addresses_attributes_0_city', with: 'Springfield')
    fill_in('prospect_addresses_attributes_0_state', with: 'HI')
    fill_in('prospect_addresses_attributes_0_postal_code', with: '12345')

    fill_in('prospect_phone_numbers_attributes_0_number', with: '301-555-0123')
    select('local', from: 'prospect_phone_numbers_attributes_0_phone_type')

    select(Enumeration.active_graduation_years.first.value, from: 'graduation_year')
    select(Enumeration.active_class_statuses.first.value, from: 'class_status')

    fill_in('prospect_email', with: 'pj@umd.edu')

    library = Enumeration.active_libraries.sample
    check("prospect_enumeration_ids_#{library.id}")

    choose('prospect_in_federal_study_true')

    click_button 'Continue'
    assert page.has_content?('Work Experience')
    click_button 'Back'

    assert page.has_field?('prospect_first_name', with: 'Polly')
    assert page.has_field?('prospect_last_name', with: 'Jane')

    assert page.has_field?('prospect_addresses_attributes_0_street_address_1', with: '555 Fake St')
    assert page.has_field?('prospect_addresses_attributes_0_city', with: 'Springfield')
    assert page.has_field?('prospect_addresses_attributes_0_state', with: 'HI')
    assert page.has_field?('prospect_addresses_attributes_0_postal_code', with: '12345')
    assert page.has_checked_field?("prospect_enumeration_ids_#{library.id}")
    assert page.has_field?('prospect_email', with: 'pj@umd.edu')
    assert page.has_field?('prospect_phone_numbers_attributes_0_number', with: '301-555-0123')
    assert page.has_field?('prospect_phone_numbers_attributes_0_phone_type', with: 'local')
    assert_equal Prospect.steps[1], page.get_rack_session_key('prospect_step')
  end
end
