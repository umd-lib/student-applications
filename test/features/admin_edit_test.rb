require 'test_helper'

feature 'Admins can edit submitted applications' do
  scenario 'login as admin & edit submitted application', js: true do
    page.current_window.resize_to(2048, 2048)

    User.create(cas_directory_id: 'editor', name: 'editor', admin: true)
    visit prospects_path
    fill_in 'username', with: 'editor'
    fill_in 'password', with: 'any password'
    click_button 'Login'

    # We should have all of our students present
    assert page.has_content?("Student, Betty")
    assert page.has_content?("Student, Alvin")
    assert page.has_content?("Stone, Rolling")

    find_link('Student, Betty').click
    find_link('Edit Submission').click
    fill_in 'prospect[first_name]', with: 'Cassie'
    fill_in 'prospect[last_name]', with: 'Nova'
    find_button('Save').click

    # We should have all of our students present, but Betty's name has changed
    refute page.has_content?("Student, Betty")
    assert page.has_content?("Nova, Cassie")
    assert page.has_content?("Student, Alvin")
    assert page.has_content?("Stone, Rolling")

  end
end
