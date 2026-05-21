# frozen_string_literal: true

require "application_system_test_case"

class FilterInFederalStudyTest < ApplicationSystemTestCase
  test "Should be able to filter prospects on federal work study" do
    page.current_window.resize_to(2048, 9999)

    User.create(cas_directory_id: "filterer", name: "filterer", admin: false)

    students = Prospect.all.group_by(&:first_name).to_h { |k, v| [ k, v.first ] } # rubocop:disable Style/HashTransformValues

    visit admin_prospects_path
    fill_in "username", with: "filterer"
    fill_in "password", with: "any password"
    click_button "Login"

    # We should have all of our students present
    page.assert_selector("#prospect_#{students['Betty'].id}")
    page.assert_selector("#prospect_#{students['Alvin'].id}")
    page.assert_selector("#prospect_#{students['Rolling'].id}")

    find("#filter-prospects").click
    assert page.find("#filter-modal").visible?

    # we select the 'Yes' radio button
    find("input#in_federal_study_yes").click
    assert find("input#in_federal_study_yes")["checked"]

    find("#submit-filter").click
    page.assert_selector("#filter-modal", visible: false)

    # only alvin is in federal work study
    page.assert_no_selector("#prospect_#{students['Betty'].id}")
    page.assert_no_selector("#prospect_#{students['Rolling'].id}")
    page.assert_selector("#prospect_#{students['Alvin'].id}")

    # We search again
    find("#filter-prospects").click
    assert page.find("#filter-modal").visible?

    # we select the 'No' radio button
    find("input#in_federal_study_no").click
    assert find("input#in_federal_study_no")["checked"]

    find("#submit-filter").click
    page.assert_selector("#filter-modal", visible: false)

    # only betty and rolling are not in federal work study
    page.assert_selector("#prospect_#{students['Betty'].id}")
    page.assert_selector("#prospect_#{students['Rolling'].id}")
    page.assert_no_selector("#prospect_#{students['Alvin'].id}")

    # We search again
    find("#filter-prospects").click
    assert page.find("#filter-modal").visible?

    # we select the 'Any' radio button
    find("input#in_federal_study_any").click
    assert find("input#in_federal_study_any")["checked"]

    find("#submit-filter").click
    page.assert_selector("#filter-modal", visible: false)

    # all prospects are shown
    page.assert_selector("#prospect_#{students['Betty'].id}")
    page.assert_selector("#prospect_#{students['Rolling'].id}")
    page.assert_selector("#prospect_#{students['Alvin'].id}")
  end
end
