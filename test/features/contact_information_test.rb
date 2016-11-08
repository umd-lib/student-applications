require 'test_helper'

# rubocop:disable Metrics/BlockLength
feature 'Enter contact information' do
  scenario 'put some basic information into the first step', js: true do
    # pretty boring test, since it's the exact same as out integration
    # test..just to get the ball rollin'
    visit root_path
    click_link 'Apply!'

    fill_in('Directory', with: 'myIdentifier')
    fill_in('prospect_first_name', with: 'Polly')
    fill_in('prospect_last_name', with: 'Jane')
    fill_in('prospect_email', with: 'pj@umd.edu')

    fill_in('prospect_addresses_attributes_0_street_address_1', with: '555 Fake St')
    fill_in('prospect_addresses_attributes_0_city', with: 'Springfield')
    fill_in('prospect_addresses_attributes_0_state', with: 'HI')
    fill_in('prospect_addresses_attributes_0_postal_code', with: '12345')

    choose('prospect_in_federal_study_true')
    click_button 'Continue'
    assert page.has_content?('Work Experience')
    assert_equal Prospect.steps.second, page.get_rack_session_key('prospect_step')
  end

  scenario 'user wants to toggle if they have a family member', js: true do
    # pretty boring test, since it's the exact same as out integration
    # test..just to get the ball rollin'
    visit root_path
    click_link 'Apply!'

    fill_in('Directory', with: 'myIdentifier')
    fill_in('prospect_first_name', with: 'Ellison')
    fill_in('prospect_last_name', with: 'James')
    fill_in('prospect_email', with: 'ej@umd.edu')

    fill_in('prospect_addresses_attributes_0_street_address_1', with: '123 Lovers Ln')
    fill_in('prospect_addresses_attributes_0_city', with: 'Juno')
    fill_in('prospect_addresses_attributes_0_state', with: 'AK')
    fill_in('prospect_addresses_attributes_0_postal_code', with: '12345')

    refute page.has_css?('#prospect_family_member', visible: true)
    find(:css, '#prospect_has_family_member_true').click
    sleep 1
    assert page.has_css?('#prospect_family_member', visible: true)
    
    choose('prospect_in_federal_study_true')

    fill_in('prospect_family_member', with: 'Lebron James')
    click_button 'Continue'
    click_button 'Back'

    # we should still have the member name
    assert page.has_css?('#prospect_family_member', visible: true)
    assert page.has_field?('prospect_family_member', with: 'Lebron James')

    # now click false and it should disapear and be erased
    find('#prospect_has_family_member_false').click
    refute page.has_field?('prospect_family_member', with: 'Lebron James')
    # reopen
    find('#prospect_has_family_member_true').click
    assert page.has_css?('#prospect_family_member', visible: true)
    assert page.has_field?('prospect_family_member', with: '')
  end

  scenario 'user wants to add multiple addresses in the contact_information page', js: true do
    visit root_path
    click_link 'Apply!'

    fill_in('Directory', with: 'myIdentifier')
    fill_in('prospect_first_name', with: 'Polly')
    fill_in('prospect_last_name', with: 'Jane')
    fill_in('prospect_email', with: 'pj@umd.edu')

    # lets add five new addresses
    2.times do |i|
      assert_equal i + 1, find(:css, '#addresses').all('.nested-fields').length

      within("#addresses .nested-fields:nth-child(#{i + 1})") do
        %w(_street_address_1 _city _state _postal_code).each do |attr|
          el_id = find("input[id$='#{attr}']")[:id]
          fill_in(el_id, with: "#{attr} #{i} ")
        end
      end
      click_link 'Add A Permanent Address' unless i == 1 
    end
    
    choose('prospect_in_federal_study_true')

    # we should do forward and back and they should all be there...
    click_button 'Continue'
    click_button 'Back'

    assert_equal 2, find(:css, '#addresses').all('.nested-fields').length

    # and with all our content
    2.times do |i|
      within("#addresses .nested-fields:nth-child(#{i + 1})") do
        %w(_street_address_1 _city _state _postal_code).each_with_index do |attr|
          el_id = find("input[id$='#{attr}']")[:id]
          assert page.has_field?(el_id, with: "#{attr} #{i} ")
        end
      end
    end
  end
end
