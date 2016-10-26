require 'test_helper'

feature "Add some work experiences" do
  scenario "add some experiences to the prospect", js: true do
    # we can fast-forward to the work_experiences step
    all_valid = prospects(:all_valid).attributes 
    page.set_rack_session( "prospect_params": all_valid )
    page.set_rack_session( "prospect_step": "work_experience")
    
    visit root_path
    click_link "Apply!" 
    assert page.has_content?("Work Experience") 
    
    click_link "Add Work Experience"
    assert_equal 1,find(:css, "#work-experiences").all(".nested-fields").length
    
    within("#work-experiences .nested-fields:nth-child(1)") do
      %w( _name _dates_of_employment _location    ).each do |attr|
          el_id =  find("input[id$='#{attr}']")[:id]
          fill_in( el_id, with: attr ) 
      end 
      %w( _duties ).each do |attr|
          el_id =  find("textarea[id$='#{attr}']")[:id]
          fill_in( el_id, with: attr ) 
      end
    end

    # we do a little dance...
    click_link "Add Work Experience"
    assert_equal 2,find(:css, "#work-experiences").all(".nested-fields").length
    
    click_button "Continue"
    click_button "Back" 
    
    assert_equal 2,find(:css, "#work-experiences").all(".nested-fields").length
     
    click_button "Back" 
    click_button "Continue"
    assert_equal 2,find(:css, "#work-experiences").all(".nested-fields").length

    # ... and values are still in place
    within("#work-experiences .nested-fields:nth-child(1)") do
      %w( _name _dates_of_employment _location  ).each_with_index do |attr|
          el_id =  find("input[id$='#{attr}']")[:id]
          assert page.has_field?( el_id, with: attr ) 
      end
      %w( _duties ).each do |attr|
          el_id =  find("textarea[id$='#{attr}']")[:id]
          assert page.has_field?( el_id, with: attr ) 
      end
    end

  end
end
