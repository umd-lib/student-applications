require 'test_helper'

# rubocop:disable Metrics/BlockLength
feature 'submit an application' do
  scenario 'just submit a standard application from start to finish', js: true do
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

    find('#prospect_has_family_member_true').click
    assert page.has_field?('prospect_family_member', visible: true, with: '')

    fill_in('prospect_family_member', with: 'Steve Blake')

    find('#prospect_in_federal_study_true').click

    click_button 'Continue'
    assert page.has_content?('Work Experience')

    click_link 'Add Work Experience'
    assert_equal 1, find(:css, '#work-experiences').all('.nested-fields').length

    within('#work-experiences .nested-fields:nth-child(1)') do
      %w(_name _dates_of_employment _location).each do |attr|
        el_id = find("input[id$='#{attr}']")[:id]
        fill_in(el_id, with: attr)
      end
      %w(_duties).each do |attr|
        el_id = find("textarea[id$='#{attr}']")[:id]
        fill_in(el_id, with: attr)
      end
    end

    click_button 'Continue'

    assert page.has_content?('Skills')
    # to do add skills test

    click_button 'Continue'
    assert page.has_content?('Availability')
    # to do add availability test
    click_button 'Continue'
    assert page.has_content?('Confirmation')
    # to do add confirmation test
    click_button 'Submit'
    assert page.has_content?('Saved')
  end
end
