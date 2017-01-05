require 'test_helper'

feature 'Add some Available Times' do
  scenario 'add some availability to the prospect', js: true do
    # we can fast-forward to the available_times step
    fixture = prospects(:all_valid)
    all_valid = fixture.attributes
    all_valid[:enumeration_ids] = fixture.enumerations.map(&:id)
    all_valid.reject! { |a| %w(id created_at updated_at).include? a }

    all_valid['addresses_attributes'] = [addresses(:all_valid_springfield).attributes.reject { |a| a == 'id' }]
    all_valid['available_times_attributes'] = [available_times(:all_valid_sunday).attributes.reject { |a| a == 'id' }]
    page.set_rack_session("prospect_params": all_valid)

    visit new_prospect_path

    10.times do
      click_button 'Continue'
      break if page.has_content?('Availability')
    end
    assert page.has_content?('Availability')

    # lets get 5 random date_times
    day_times = [*0..3].map do
      [*0..6].sample
    end.inject([]) do |c, v|
      val = "#{v}-#{[*0..23].sample}"
      redo if c.include?(val)
      c << val
    end
    # lets click the 5 tds related to that checkbox
    day_times.each do |dt|
      find(:css, "input[value='#{dt}']", visible: false).first(:xpath, './/../..').trigger(:click)
    end

    assert_equal 5, find_all(:css, 'input[type=checkbox]:checked', visible: false).length
    assert_equal 5, find_all(:css, 'td.success').length

    # we do a little dance...
    click_button 'Continue'
    click_button 'Back'

    assert_equal 5, find_all(:css, 'input[type=checkbox]:checked', visible: false).length
    assert_equal 5, find_all(:css, 'td.success').length
  end

  scenario 'make sure our total times is in line with the times available', js: true do
    # we can fast-forward to the available_times step
    fixture = prospects(:all_valid)
    all_valid = fixture.attributes
    all_valid[:enumeration_ids] = fixture.enumerations.map(&:id)
    all_valid.reject! { |a| %w(id created_at updated_at).include? a }

    all_valid['addresses_attributes'] = [addresses(:all_valid_springfield).attributes.reject { |a| a == 'id' }]
    all_valid['available_times_attributes'] = [available_times(:all_valid_sunday).attributes.reject { |a| a == 'id' }]
    page.set_rack_session("prospect_params": all_valid)

    visit new_prospect_path

    10.times do
      click_button 'Continue'
      break if page.has_content?('Availability')
    end
    assert page.has_content?('Availability')

    # like before,  lets get 5 random date_times
    day_times = [*0..3].map do
      [*0..6].sample
    end.inject([]) do |c, v|
      val = "#{v}-#{[*0..23].sample}"
      redo if c.include?(val)
      c << val
    end
    # lets click the 5 tds related to that checkbox
    day_times.each do |dt|
      find(:css, "input[value='#{dt}']", visible: false).first(:xpath, './/../..').trigger(:click)
    end

    # but let's put the total times higher..
    fill_in('prospect_available_hours_per_week', with: 10_000)

    assert_equal 5, find_all(:css, 'input[type=checkbox]:checked', visible: false).length
    assert_equal 5, find_all(:css, 'td.success').length

    # we do a little dance...
    click_button 'Continue'
    assert page.has_content?('Availability')
    assert page.has_content?("can't be greater than the number of available times provided")

    fill_in('prospect_available_hours_per_week', with: 5)

    click_button 'Continue'
    click_button 'Back'

    assert page.has_field?('prospect_available_hours_per_week', visible: true, with: 5)
    assert_equal 5, find_all(:css, 'input[type=checkbox]:checked', visible: false).length
    assert_equal 5, find_all(:css, 'td.success').length
  end
end
