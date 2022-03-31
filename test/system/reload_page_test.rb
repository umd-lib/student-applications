# frozen_string_literal: true

require 'application_system_test_case'

class ReloadPageTest < ApplicationSystemTestCase
  test 'Refresh during an application should cause any problems' do
    # we can fast-forward to the skills step
    all_valid = prospects(:all_valid).attributes
    page.set_rack_session(prospect_params: all_valid)
    page.set_rack_session(prospect_step: 'skills')

    visit new_prospect_path
    assert page.has_content?('Skills')

    skill_id = "prospect_skill_ids_#{Skill.promoted.sample.id}"
    check skill_id

    # add some skills to the prospect
    click_link 'Add Skill'
    assert_equal 1, find(:css, '#skills').all('.nested-fields').length

    within('#skills .nested-fields:nth-child(1)') do
      el_id = find("input[id$='_name']")[:id]
      fill_in(el_id, with: 'C00king')
    end

    click_button 'Continue'
    # and now REFRESH!
    assert page.has_content?('Availability')
    page.evaluate_script('window.location.reload()')
    assert page.has_content?('Availability')
    click_button 'Back'
    click_button 'Back' unless page.has_content?('Skills')
    assert page.has_content?('Skills')

    within('#skills .nested-fields:nth-child(1)') do
      el_id = find("input[id$='_name']")[:id]
      assert page.has_field?(el_id, with: 'C00king')
    end
    assert page.has_checked_field?(skill_id)

    click_button 'Back'
    click_button 'Continue'

    within('#skills .nested-fields:nth-child(1)') do
      el_id = find("input[id$='_name']")[:id]
      assert page.has_field?(el_id, with: 'C00king')
    end
    assert page.has_checked_field?(skill_id)
  end
end
