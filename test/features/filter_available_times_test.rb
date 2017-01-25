require 'test_helper'

# rubocop:disable Metric/BlockLength
feature 'Should be able filter prospects on available times' do
  scenario 'login as user & filter', js: true do
    page.driver.resize_window(2048, 2048)

    User.create(cas_directory_id: 'filterer', name: 'filterer', admin: false)
    visit prospects_path
    fill_in 'username', with: 'filterer'
    fill_in 'password', with: 'any password'
    click_button 'Login'

    # Our Students....
    # rubocop:disable Rails/SkipsModelValidations
    Prospect.find_by(first_name: 'Betty').update_attribute(:day_times, ['0-9', '0-10', '0-11'])
    Prospect.find_by(first_name: 'Alvin').update_attribute(:day_times, ['0-8', '0-9'])
    Prospect.find_by(first_name: 'Rolling').update_attribute(:day_times, ['1-8', '1-9', '1-10'])
    # rubocop:ensable Rails/SkipsModelValidations
    
    students = Prospect.all.group_by(&:first_name).map { |k,v| [k, v.first] }.to_h

    # We should have all of our students present
    # We should have all of our students present
    page.must_have_selector("#prospect_#{ students["Betty"].id  }") 
    page.must_have_selector("#prospect_#{ students["Alvin"].id  }") 
    page.must_have_selector("#prospect_#{ students["Rolling"].id  }") 

    find('#filter-prospects').click
    assert page.find( "#filter-modal" ).visible? 

    find('#available_time-0-9').trigger(:click)
    assert find("input#available_time-0-9")["checked"]
    
    find('#submit-filter').trigger(:click)
    page.wont_have_selector( "#filter-modal" ) 
    
    # check for prospects with the first time; should be two out of three
    page.must_have_selector("#prospect_#{ students["Betty"].id  }") 
    page.must_have_selector("#prospect_#{ students["Alvin"].id  }") 
    page.wont_have_selector("#prospect_#{ students["Rolling"].id  }") 

    find('#filter-prospects').click
    page.must_have_selector( "#filter-modal" ) 

    # check for prospects with both times; should only be one
    find('#available_time-0-10').trigger(:click)
    assert find("input#available_time-0-9")["checked"]
    assert find("input#available_time-0-10")["checked"]
    assert_equal 2, all('.available_time').select(&:checked?).length
    
    find('#submit-filter').click
    page.wont_have_selector( "#filter-modal" ) 
    
    page.must_have_selector("#prospect_#{ students["Betty"].id  }") 
    page.wont_have_selector("#prospect_#{ students["Rolling"].id  }") 
    page.wont_have_selector("#prospect_#{ students["Alvin"].id  }") 

  end
end
