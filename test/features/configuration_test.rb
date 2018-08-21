require 'test_helper'


feature 'Should be able to configuration that application' do

  scenario 'admin should be able to promote and unpromote skills', js: true do
    page.current_window.resize_to(2048, 2048)
    User.create(cas_directory_id: 'admin', name: 'admin', admin: true)
    visit configuration_path
    # Visiting prospects_path should redirect to CAS
    fill_in 'username', with: 'admin'
    fill_in 'password', with: 'any password'
    click_button 'Login'

    click_link 'SKILLS'

    skill = Skill.promoted.first
    assert skill.promoted?
    assert page.has_content?(skill.name)


    find(:css, "#skill_#{skill.id} .toggle:not(.off)").click
    page.must_have_selector  "#skill_#{skill.id} .toggle.off"
    sleep 1

    refute skill.reload.promoted?
    find(:css, "#skill_#{skill.id} .toggle").click
    page.must_have_selector  "#skill_#{skill.id} .toggle:not(.off)"
    sleep 1
    assert skill.reload.promoted?
  end

  scenario 'admin should be able to activate and unactivate enumeration', js: true do
    page.current_window.resize_to(2048, 2048)
    User.create(cas_directory_id: 'admin', name: 'admin', admin: true)
    visit configuration_path
    # Visiting prospects_path should redirect to CAS
    fill_in 'username', with: 'admin'
    fill_in 'password', with: 'any password'
    click_button 'Login'

    list = Enumeration.lists.keys.first.pluralize
    click_link list.humanize.upcase

    enum = Enumeration.send("active_#{list}".intern).first
    assert enum.active?
    assert page.has_content?(enum.value)


    find(:css, "#enumeration_#{enum.id} .toggle:not(.off)").click
    page.must_have_selector  "#enumeration_#{enum.id} .toggle.off"
    sleep(1)
    refute enum.reload.active?
    find(:css, "#enumeration_#{enum.id} .toggle").click
    page.must_have_selector  "#enumeration_#{enum.id} .toggle:not(.off)"
    sleep(1)
    assert enum.reload.active?
  end

  scenario 'admin should be able to create enumeration', js: true do
    page.current_window.resize_to(2048, 2048)
    User.create(cas_directory_id: 'admin', name: 'admin', admin: true)
    visit configuration_path
    # Visiting prospects_path should redirect to CAS
    fill_in 'username', with: 'admin'
    fill_in 'password', with: 'any password'
    click_button 'Login'

    list = Enumeration.lists.keys.first
    click_link list.pluralize.humanize.upcase
    assert page.must_have_selector "#enumeration-#{list}.collapse.in"

    assert_difference( 'Enumeration.count' ) do
      find(:css, "input#enumeration_#{list}_value").send_keys "phd", :enter
      assert page.has_content?("phd")
    end

  end

  scenario 'admin should be able to create enumerat', js: true do
    page.current_window.resize_to(2048, 2048)
    User.create(cas_directory_id: 'admin', name: 'admin', admin: true)
    visit configuration_path
    # Visiting prospects_path should redirect to CAS
    fill_in 'username', with: 'admin'
    fill_in 'password', with: 'any password'
    click_button 'Login'

    click_link 'SKILLS'
    assert page.must_have_selector "#skills.collapse.in"

    assert_difference( 'Skill.count' ) do
      find(:css, "input#new_skill_name").send_keys "programming", :enter
      assert page.has_content?("programming")
    end
  end

end
