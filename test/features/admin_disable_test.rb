require 'test_helper'

feature 'Should be able to login as admin and disable it temporarly' do
  scenario 'login as admin, look around, then test the disable', js: true do
    page.driver.resize_window(2048, 2048)
    User.create(cas_directory_id: 'admin', name: 'admin', admin: true)
    visit prospects_path
    # Visiting prospects_path should redirect to CAS
    fill_in 'username', with: 'admin'
    fill_in 'password', with: 'any password'
    click_button 'Login'

    assert page.has_content?('User Management')
    click_link 'Review Applications'
    click_link 'User Management'
    click_link 'Disable Admin'

    assert page.has_content?(
      'You have temporarly disabled admin functionality. Sign out and log back in to restore admin role.'
    )
    assert_equal 10, page.find_all('th').length
    refute page.has_content?('User Management')
  end
end
