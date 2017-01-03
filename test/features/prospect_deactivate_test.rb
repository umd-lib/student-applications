require 'test_helper'

feature 'Should be able to login as admin and deactivate applications' do
  scenario 'login as admin and deactivate applications', js: true do
    page.driver.resize_window(2048, 2048)
    User.create(cas_directory_id: 'admin', name: 'admin', admin: true)
    visit root_path
    click_link 'Staff Sign-In'
    fill_in 'username', with: 'admin'
    fill_in 'password', with: 'any password'
    click_button 'Login'

    assert page.has_content?('User Management')
    click_link 'Review Applications'
    sleep(2) 
    row_count = all( "input.deactivate" ).length 
    all( "input.deactivate" ).last.click
    find( "#deactivate-prospects" ).click 
    assert page.has_content?('Are You Sure You Want To Delete The Following Applications?')
    find( "#submit-deactivate" ).click
    sleep(1) 
    assert_equal 1, all('tr.danger').length
    page.evaluate_script("window.location.reload()")
    assert_equal (row_count - 1), all( "input.deactivate" ).length 
  end
end
