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

    # We should have all of our students present
    assert page.has_content?('Student, Betty')
    assert page.has_content?('Student, Alvin')
    assert page.has_content?('Stone, Rolling')

    find('#filter-prospects').click
    assert page.has_content?('Filter Applications')

    find('#available_time-0-9').click
    sleep(2)
    assert_equal 1, all('.available_time').select(&:checked?).length
    assert find('#available_time-0-9').checked?
    find('#submit-filter').click

    # check for prospects with the first time; should be two out of three
    assert page.has_content?('Student, Betty')
    assert page.has_content?('Student, Alvin')
    refute page.has_content?('Stone, Rolling')

    find('#filter-prospects').click
    assert page.has_content?('Filter Applications')

    # check for prospects with both times; should only be one
    find('#available_time-0-10').click
    sleep(2)
    assert_equal 2, all('.available_time').select(&:checked?).length
    assert find('#available_time-0-9').checked?
    assert find('#available_time-0-10').checked?
    find('#submit-filter').click

    assert page.has_content?('Student, Betty')
    refute page.has_content?('Student, Alvin')
    refute page.has_content?('Stone, Rolling')
  end
end
