require 'test_helper'

feature 'Verify "Reset" button functionality' do
  scenario 'put some basic information into the first step and hit "Reset"', js: true do
    page.driver.resize_window(2048, 2048)
    visit root_path
    click_link 'Apply!'
    
    fill_in('Directory', with: 'myIdentifier')
    choose(Enumeration.active_semesters.first.value)
    click_button 'Continue'

    assert page.has_link?('navbar-reset-link')
    fill_in('prospect_first_name', with: 'Polly')
    fill_in('prospect_last_name', with: 'Jane')
    fill_in('prospect_email', with: 'pj@umd.edu')

    assert page.has_field?('prospect_first_name', with: 'Polly')
    assert page.has_field?('prospect_last_name', with: 'Jane')
    assert page.has_field?('prospect_email', with: 'pj@umd.edu')

    # Click 'Reset' link, and confirm in the dialog.
    accept_confirm do
      click_link 'navbar-reset-link'
    end

    # This sends us back to the home page, so click Apply and verify empty
    # fields.
    click_link 'Apply!'
    assert page.has_field?('Directory', with: '')
  
  end
end
