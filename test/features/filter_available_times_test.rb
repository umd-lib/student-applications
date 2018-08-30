require 'test_helper'

# rubocop:disable Metric/BlockLength
feature 'Should be able filter prospects on available times' do
  scenario 'login as user & filter', js: true do
    page.current_window.resize_to(2048, 2048)

    User.create(cas_directory_id: 'filterer', name: 'filterer', admin: false)
    visit prospects_path
    fill_in 'username', with: 'filterer'
    fill_in 'password', with: 'any password'
    click_button 'Login'

    # Our Students....
    set_day_times(Prospect.find_by(first_name: 'Betty'), ['0-9', '0-10', '0-11'])
    set_day_times(Prospect.find_by(first_name: 'Alvin'), ['0-8', '0-9'])
    set_day_times(Prospect.find_by(first_name: 'Rolling'), ['1-8', '1-9', '1-10'])

    students = Prospect.all.group_by(&:first_name).map { |k,v| [k, v.first] }.to_h

    # We should have all of our students present
    page.must_have_selector("#prospect_#{ students["Betty"].id  }")
    page.must_have_selector("#prospect_#{ students["Alvin"].id  }")
    page.must_have_selector("#prospect_#{ students["Rolling"].id  }")

    find('#filter-prospects').click
    assert page.find( "#filter-modal" ).visible?

    find('#available_time-0-9').click
    assert find("input#available_time-0-9")["checked"]

    find('#submit-filter').click
    page.wont_have_selector( "#filter-modal" )

    # check for prospects with the first time; should be two out of three
    page.must_have_selector("#prospect_#{ students["Betty"].id  }")
    page.must_have_selector("#prospect_#{ students["Alvin"].id  }")
    page.wont_have_selector("#prospect_#{ students["Rolling"].id  }")

    find('#filter-prospects').click
    page.must_have_selector( "#filter-modal" )

    # check for prospects with both times; should only be one
    find('#available_time-0-10').click
    assert find("input#available_time-0-9")["checked"]
    assert find("input#available_time-0-10")["checked"]
    assert_equal 2, all('.available_time').select(&:checked?).length

    find('#submit-filter').click
    page.wont_have_selector( "#filter-modal" )

    page.must_have_selector("#prospect_#{ students["Betty"].id  }")
    page.wont_have_selector("#prospect_#{ students["Rolling"].id  }")
    page.wont_have_selector("#prospect_#{ students["Alvin"].id  }")

  end

  # Helper method for setting an array of day_times on a prospect and then
  # storing
  def set_day_times(prospect, day_times)
    prospect.day_times = day_times
    prospect.save!
  end
end
