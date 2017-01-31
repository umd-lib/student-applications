require 'test_helper'

feature 'Admins can see the delayed jobs page' do
  scenario 'admins can see the delayed job page', js: true do
    User.create(cas_directory_id: 'editor', name: 'editor', admin: true)
    visit prospects_path
    fill_in 'username', with: 'editor'
    fill_in 'password', with: 'any password'
    click_button 'Login'
    
    visit "/delayed_jobs"

    assert page.has_content?("Overview")

  end
  
  scenario 'nonadmins cannot see the delayed job page', js: true do
    User.create(cas_directory_id: 'someone', name: 'someone', admin: false)
    visit prospects_path
    fill_in 'username', with: 'someone'
    fill_in 'password', with: 'any password'
    click_button 'Login'
    
    visit "/delayed_jobs"

    assert page.has_content?("Unauthorized")

  end
  
  scenario 'unauthed visitors cannot see the delayed job page', js: true do
    visit "/delayed_jobs"
    assert page.has_content?("Unauthorized")
  end

end
