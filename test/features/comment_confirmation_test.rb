require 'test_helper'

feature 'Comment Confirmation page' do
  scenario 'go to the page and follow the change links', js: true do
    # we can fast-forward to the skills step
    fixture = prospects(:all_valid)
    all_valid = fixture.attributes
    all_valid[:enumeration_ids] = fixture.enumerations.map(&:id)
    all_valid.reject! { |a| %w(id created_at updated_at).include? a }

    all_valid[:directory_id] = SecureRandom.hex
    all_valid[:semester] = Enumeration.active_semesters.first.value
    all_valid[:available_hours_per_week] = 0

    all_valid['addresses_attributes'] = [addresses(:all_valid_springfield).attributes.reject { |a| a == 'id' }]
    all_valid['phone_numbers_attributes'] = [phone_numbers(:all_valid_dummy).attributes.reject { |a| a == 'id' }]

    page.set_rack_session("prospect_params": all_valid)
    page.set_rack_session("prospect_step": 'comments_confirmation')

    visit new_prospect_path
    assert page.has_content?('Confirmation')
    assert page.has_content?('Fall 2017')

    [ 'Applicant Info', 'Contact Info', 'Work Experience', 'Skills', 'Availability', 'Resume'].each do |step|

      click_link("Change #{step}")

      # Applicant Info step does not have a specific H2 page header, so we need
      # to look for something different, otherwise just use "step"
      if (step == 'Applicant Info')
        within('h4') do
          assert page.has_content?('Please enter your Student ID')
        end
      else
        within('h2') do
          assert page.has_content?(step)
        end
      end

      # cycle back to the confirmation page
      10.times do
        click_button 'Continue'
        break if page.has_content?('Confirmation')
      end
    end
  end
end
