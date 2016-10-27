require 'test_helper'

feature 'Add some Available Times' do
  scenario 'add some availability to the prospect', js: true do
    # we can fast-forward to the available_times step
    all_valid = prospects(:all_valid).attributes
    page.set_rack_session("prospect_params": all_valid)

    visit root_path
    click_link 'Apply!'

    click_button 'Continue' until page.has_content?('Availability')
    # lets get 5 random date_times
    day_times = [*0..4].map do
      [*0..6].sample
    end.inject([]) do |c, v|
      val = "#{v}-#{[*0..23].sample}"
      redo if c.include?(val)
      c << val
    end
    # lets click the 5 tds related to that checkbox
    day_times.each do |dt|
      find(:css, "input[value='#{dt}']", visible: false).first(:xpath, './/../..').click
    end

    assert_equal 5, find_all(:css, 'input[type=checkbox]:checked', visible: false).length
    assert_equal 5, find_all(:css, 'td.success').length

    # we do a little dance...
    click_button 'Continue'
    click_button 'Back'

    assert_equal 5, find_all(:css, 'input[type=checkbox]:checked', visible: false).length
    assert_equal 5, find_all(:css, 'td.success').length
  end
end
