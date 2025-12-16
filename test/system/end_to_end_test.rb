# frozen_string_literal: true

require "application_system_test_case"
require "securerandom"

class EndToEndTest < ApplicationSystemTestCase
  test "submit a standard application from start to finish" do
    # pretty boring test, since it's the exact same as out integration
    # test..just to get the ball rollin'
    visit root_path
    click_link "Apply!"

    fill_in("Directory", with: "myIdentifier")
    choose(Enumeration.active_semesters.first.value)
    click_button "Continue"

    fill_in("prospect_first_name", with: "Polly")
    fill_in("prospect_last_name", with: "Jane")

    email_addr = "#{SecureRandom.hex}@umd.edu"
    fill_in("prospect_email", with: email_addr)

    fill_in("prospect_addresses_attributes_0_street_address_1", with: "555 Fake St")
    fill_in("prospect_addresses_attributes_0_city", with: "Springfield")
    fill_in("prospect_addresses_attributes_0_state", with: "HI")
    fill_in("prospect_addresses_attributes_0_postal_code", with: "12345")

    fill_in("prospect_phone_numbers_attributes_0_number", with: "301-555-0123")
    select("local", from: "prospect_phone_numbers_attributes_0_phone_type")

    select(Enumeration.active_graduation_years.first.value, from: "graduation_year")
    select(Enumeration.active_class_statuses.first.value, from: "class_status")

    find("#prospect_in_federal_study_true").click

    click_button "Continue"
    assert page.has_content?("Work Experience")

    click_link "Add Work Experience"
    assert_equal 1, find(:css, "#work-experiences").all(".nested-fields").length

    within("#work-experiences .nested-fields:nth-child(1)") do
      %w[_name _dates_of_employment _location].each do |attr|
        el_id = find("input[id$='#{attr}']")[:id]
        fill_in(el_id, with: attr)
      end
      %w[_duties].each do |attr|
        el_id = find("textarea[id$='#{attr}']")[:id]
        fill_in(el_id, with: attr)
      end
    end

    click_button "Continue"

    assert page.has_content?("Skills")
    # to do add skills test
    skill = Skill.promoted.first
    check "prospect_skill_ids_#{skill.id}"

    click_link "Add Skill"
    within("#skills .nested-fields:nth-child(1)") do
      el_id = find("input[id$='_name']")[:id]
      fill_in(el_id, with: "zzzyyyqqq")
    end
    skills = [ skill.name, "zzzyyyqqq" ]

    click_button "Continue"
    assert page.has_content?("Availability")
    # to do add availability test
    click_button "Continue"
    assert page.has_content?("Resume")
    click_button "Continue"
    assert page.has_content?("Confirmation")

    skills.each do |s|
      assert_selector "li", text: s
    end

    # to do add confirmation test

    # need to fix this. running into a db lock. switch to database_cleaner
    check("prospect_user_confirmation")
    fill_in("prospect_user_signature", with: "Bob Bob")

    click_button "Submit"

    assert page.has_content?("Submitted")
    visit root_path
    assert page.has_content?("Apply")

    email = ActionMailer::Base.deliveries.last
    assert_equal email.to.first, email_addr

    # now we should not be able to resubmit
    click_link "Apply!"

    fill_in("Directory", with: "myIdentifier")
    choose(Enumeration.active_semesters.first.value)
    click_button "Continue"

    assert_not page.has_content?("Contact Information")
    assert page.has_content?("Please note that this directory ID has already submitted an application")

    fill_in("Directory", with: SecureRandom.hex)
    click_button "Continue"
    assert_not page.has_content?("Please note that this directory ID has already submitted an application")
    assert page.has_content?("Contact Information")
  end
end
