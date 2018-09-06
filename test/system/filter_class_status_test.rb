require 'application_system_test_case'

class FilterClassStatusTest < ApplicationSystemTestCase
  test 'Should be able filter prospects on class status' do
    page.current_window.resize_to(2048, 9999)

    undergrad = Enumeration.find_by( value: "Undergraduate" ).id
    User.create(cas_directory_id: 'filterer', name: 'filterer', admin: false)

    students = Prospect.all.group_by(&:first_name).map { |k,v| [k, v.first] }.to_h

    visit prospects_path
    fill_in 'username', with: 'filterer'
    fill_in 'password', with: 'any password'
    click_button 'Login'

    # We should have all of our students present
    page.assert_selector("#prospect_#{ students["Betty"].id  }")
    page.assert_selector("#prospect_#{ students["Alvin"].id  }")
    page.assert_selector("#prospect_#{ students["Rolling"].id  }")

    find("#filter-prospects").click
    assert page.find( "#filter-modal" ).visible?

    # we tweak the slider...
    find("input#class_status_#{undergrad}").click
    assert find("input#class_status_#{undergrad}")["checked"]

    find("#submit-filter").click
    page.assert_selector( "#filter-modal", visible: false )

    # only alvin is an undergrad
    page.refute_selector("#prospect_#{ students["Betty"].id  }")
    page.refute_selector("#prospect_#{ students["Rolling"].id  }")
    page.assert_selector("#prospect_#{ students["Alvin"].id  }")
  end
end
