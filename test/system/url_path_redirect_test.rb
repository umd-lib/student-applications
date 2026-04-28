# frozen_string_literal: true

require "application_system_test_case"

class UrlPathRedirectTest < ApplicationSystemTestCase
  test "/prospects redirects to /prospects/new when application in progress" do
    all_valid = prospects(:all_valid).attributes
    page.set_rack_session(prospect_params: all_valid)
    visit "/prospects"
    assert_equal new_prospect_path, page.current_path
  end

  test "/prospects redirects to /admin/prospects when no application in progress" do
    visit "/prospects"
    assert_equal admin_prospects_path, page.current_path
  end

  test "/admin redirects to /admin/prospects" do
    visit "/admin"
    assert_equal admin_prospects_path, page.current_path
  end
end
