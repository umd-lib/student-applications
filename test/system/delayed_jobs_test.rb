# frozen_string_literal: true

require "application_system_test_case"

class DelayedJobsTest < ApplicationSystemTestCase
  test "admins can see the delayed job page" do
    User.create(cas_directory_id: "editor", name: "editor", admin: true)
    visit prospects_path
    fill_in "username", with: "editor"
    fill_in "password", with: "any password"
    click_button "Login"

    visit "/delayed_jobs"

    assert page.has_content?("Overview")
  end

  test "nonadmins cannot see the delayed job page" do
    User.create(cas_directory_id: "someone", name: "someone", admin: false)
    visit prospects_path
    fill_in "username", with: "someone"
    fill_in "password", with: "any password"
    click_button "Login"

    visit "/delayed_jobs"

    assert page.has_content?("Unauthorized")
  end

  test "unauthed visitors cannot see the delayed job page" do
    visit "/delayed_jobs"
    assert page.has_content?("Unauthorized")
  end
end
