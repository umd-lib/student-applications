require 'test_helper'

feature 'Should be able filter prospects on class status' do
  scenario 'login as user & filter', js: true do
    page.driver.resize_window(2048, 2048)

    undergrad = Enumeration.find_by( value: "Undergraduate" ).id
    

    User.create(cas_directory_id: 'filterer', name: 'filterer', admin: false)
    visit prospects_path
    fill_in 'username', with: 'filterer'
    fill_in 'password', with: 'any password'
    click_button 'Login'

    # We should have all of our students present
    assert page.has_content?("Student, Betty") 
    assert page.has_content?("Student, Alvin") 
    assert page.has_content?("Stone, Rolling") 

    find("#filter-prospects").click
    page.must_have_selector( "#filter-modal", visible: true ) 
  
    # we tweak the slider...
    check("class_status_#{undergrad}") 
    
    find("#submit-filter").click
    page.must_have_selector( "#filter-modal", visible: false ) 

    # only alvin is an undergrad 
    assert page.has_content?("Student, Alvin") 
    refute page.has_content?("Student, Betty") 
    refute page.has_content?("Stone, Rolling") 
  end
end
