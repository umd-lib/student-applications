# frozen_string_literal: true

require "application_system_test_case"

class SortTest < ApplicationSystemTestCase
  test "Prospects can be sorted by semester" do
    page.current_window.resize_to(2048, 2048)

    # Remove all the "Filter" students for simpler verification
    Prospect.where(first_name: "Filter").destroy_all

    User.create(cas_directory_id: "sorter", name: "sorter", admin: false)
    visit prospects_path
    fill_in "username", with: "sorter"
    fill_in "password", with: "any password"
    click_button "Login"

    # Our Students....
    Prospect.find_by(first_name: "Alvin").update_attribute(:semester, enumerations(:spring_2017)) # rubocop:disable Rails/SkipsModelValidations
    Prospect.find_by(first_name: "Betty").update_attribute(:semester, enumerations(:fall_2017)) # rubocop:disable Rails/SkipsModelValidations
    Prospect.find_by(first_name: "Rolling").update_attribute(:semester, enumerations(:spring_2018)) # rubocop:disable Rails/SkipsModelValidations

    # Retrieve all the entries in the "Name" column in the table
    sorted_names = []
    page.all(:xpath, "//table/tbody/tr/td[1]").each do |td|
      sorted_names << td.text
    end

    assert_equal(["Stone, Rolling", "Student, Betty", "Student, Alvin"], sorted_names)

    # click a sort link
    click_link("Semester")
    sleep(2)

    # Retrieve all the entries in the 'Name' column in the table
    sorted_names = []
    page.all(:xpath, "//table/tbody/tr/td[1]").each do |td|
      sorted_names << td.text
    end

    # Sort is now in alphabetical order by semester name
    assert_equal(["Student, Betty", "Student, Alvin", "Stone, Rolling"], sorted_names)
  end
end
