require 'test_helper'

feature 'Should be able filter prospects on class status' do
  scenario 'login as user & filter', js: true do
    page.current_window.resize_to(2048, 9999)

    undergrad = Enumeration.find_by( value: "Undergraduate" ).id
    User.create(cas_directory_id: 'filterer', name: 'filterer', admin: false)

    students = Prospect.all.group_by(&:first_name).map { |k,v| [k, v.first] }.to_h

    visit prospects_path
    fill_in 'username', with: 'filterer'
    fill_in 'password', with: 'any password'
    click_button 'Login'

    # We should have all of our students present
    page.must_have_selector("#prospect_#{ students["Betty"].id  }")
    page.must_have_selector("#prospect_#{ students["Alvin"].id  }")
    page.must_have_selector("#prospect_#{ students["Rolling"].id  }")

    find("#filter-prospects").click
    assert page.find( "#filter-modal" ).visible?

    # we tweak the slider...
    find("input#class_status_#{undergrad}").click
    assert find("input#class_status_#{undergrad}")["checked"]

    find("#submit-filter").click
    page.must_have_selector( "#filter-modal", visible: false )

    # only alvin is an undergrad
    page.wont_have_selector("#prospect_#{ students["Betty"].id  }")
    page.wont_have_selector("#prospect_#{ students["Rolling"].id  }")
    page.must_have_selector("#prospect_#{ students["Alvin"].id  }")
  end
end
