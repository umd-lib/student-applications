require 'test_helper'

# Integration test for submitting the application form
class SubmitProspectApplicationTest < ActionDispatch::IntegrationTest
  test 'starting an application' do
    Capybara.using_session('bad contact info') do
      visit '/'
      click_link 'Apply!'
      assert page.has_content?('Contact Information')
    end
  end

  test "won't go past contact information if the values are not present" do
    Capybara.using_session('bad contact info') do
      visit '/'
      click_link 'Apply!'
      assert page.has_content?('Contact Information')
      click_button 'Continue'
      assert page.has_content?('Contact Information')
      assert page.has_content?("can't be blank")
      assert_equal Prospect.steps.first, page.get_rack_session_key('prospect_params')['current_step']
    end
  end

  test 'that it can create contact information and proceed to next step' do
    Capybara.using_session('good contact info') do
      visit '/'
      click_link 'Apply!'

      fill_in('Directory', with: 'myIdentifier')
      fill_in('prospect_first_name', with: 'Polly')
      fill_in('prospect_last_name', with: 'Jane')

      fill_in('prospect_addresses_attributes_0_street_address_1', with: '555 Fake St')
      fill_in('prospect_addresses_attributes_0_city', with: 'Springfield')
      fill_in('prospect_addresses_attributes_0_state', with: 'HI')
      fill_in('prospect_addresses_attributes_0_postal_code', with: '12345')

      fill_in('prospect_email', with: 'pj@umd.edu')
      choose('prospect_in_federal_study_true')

      click_button 'Continue'
      assert page.has_content?('Work Experience')
      assert_equal Prospect.steps.second, page.get_rack_session_key('prospect_step')
    end
  end

  test 'that it can keeps values while proceeding to next step or going back' do
    Capybara.using_session('more good contact info') do
      visit '/'
      click_link 'Apply!'

      fill_in('Directory', with: 'myIdentifier')
      fill_in('prospect_first_name', with: 'Polly')
      fill_in('prospect_last_name', with: 'Jane')

      fill_in('prospect_addresses_attributes_0_street_address_1', with: '555 Fake St')
      fill_in('prospect_addresses_attributes_0_city', with: 'Springfield')
      fill_in('prospect_addresses_attributes_0_state', with: 'HI')
      fill_in('prospect_addresses_attributes_0_postal_code', with: '12345')

      fill_in('prospect_email', with: 'pj@umd.edu')

      choose('prospect_in_federal_study_true')
      click_button 'Continue'
      assert page.has_content?('Work Experience')
      click_button 'Back'

      assert page.has_field?('Directory', with: 'myIdentifier')
      assert page.has_field?('prospect_first_name', with: 'Polly')
      assert page.has_field?('prospect_last_name', with: 'Jane')

      assert page.has_field?('prospect_addresses_attributes_0_street_address_1', with: '555 Fake St')
      assert page.has_field?('prospect_addresses_attributes_0_city', with: 'Springfield')
      assert page.has_field?('prospect_addresses_attributes_0_state', with: 'HI')
      assert page.has_field?('prospect_addresses_attributes_0_postal_code', with: '12345')

      assert page.has_field?('prospect_email', with: 'pj@umd.edu')
      assert_equal Prospect.steps.first, page.get_rack_session_key('prospect_step')
    end
  end
end
