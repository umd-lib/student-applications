# frozen_string_literal: true

require "application_system_test_case"

class AdminDisableTest < ApplicationSystemTestCase
  test "Should be able to login as admin and disable it temporarily" do
    page.current_window.resize_to(2048, 2048)
    User.create(cas_directory_id: "admin", name: "admin", admin: true)
    visit prospects_path
    # Visiting prospects_path should redirect to CAS
    fill_in "username", with: "admin"
    fill_in "password", with: "any password"
    click_button "Login"

    assert page.has_content?("User Management")
    click_link "Review Applications"
    click_link "User Management"
    click_link "Disable Admin"

    assert page.has_content?(
      "You have temporarly disabled admin functionality. Sign out and log back in to restore admin role."
    )
    assert_equal 10, page.find_all("th").length
    assert_not page.has_content?("User Management")
  end
end
