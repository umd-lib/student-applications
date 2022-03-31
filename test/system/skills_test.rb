# frozen_string_literal: true

require 'application_system_test_case'

class SkillsTest < ApplicationSystemTestCase
  test 'add some skills to the prospect' do
    # we can fast-forward to the skills step
    all_valid = prospects(:all_valid).attributes
    page.set_rack_session(prospect_params: all_valid)
    page.set_rack_session(prospect_step: 'skills')

    visit new_prospect_path
    assert page.has_content?('Skills')

    skill_id = "prospect_skill_ids_#{Skill.promoted.sample.id}"
    check skill_id

    click_link 'Add Skill'
    assert_equal 1, find(:css, '#skills').all('.nested-fields').length

    within('#skills .nested-fields:nth-child(1)') do
      el_id = find("input[id$='_name']")[:id]
      fill_in(el_id, with: 'C00king')
    end

    click_button 'Continue'
    click_button 'Back'

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
