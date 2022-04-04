# frozen_string_literal: true

require 'test_helper'
require 'rake'
require './lib/tasks/sample_prospect_creator'

class PurgeSuppressedProspectsTest < ActiveSupport::TestCase
  # Relative directory when prospect resumes are stored
  RESUME_STORAGE_DIR = 'resumes'

  def with_captured_stdout
    # capture previous value of $stdout
    original_stdout = $stdout
    # assign a string buffer to $stdout
    $stdout = StringIO.new
    # perform the body of the user code
    yield
    # return the contents of the string buffer
    $stdout.string
  ensure
    # restore $stdout to its previous value
    $stdout = original_stdout
  end

  def setup
    OnlineStudentApplications::Application.load_tasks if Rake::Task.tasks.empty?

    # Need to reseed the database each time, because database is destroyed
    # between tests
    Rake::Task['db:seed'].reenable
    Rake::Task['db:seed'].invoke
    Rake::Task['db:purge_suppressed_prospects'].reenable
  end

  test 'old active prospect is not purged' do
    # Destroy all existing prospects (from fixtures)
    Prospect.destroy_all

    # Create an active (i.e., unsuppressed) prospect last updated 6 month ago
    create_active_prospect(last_update: 6.months.ago)

    assert_no_difference ['Prospect.count', 'Resume.count', 'resume_file_count'] do
      with_captured_stdout do
        Rake::Task['db:purge_suppressed_prospects'].invoke
      end
    end
  end

  test 'old suppressed prospect is not purged' do
    # Destroy all existing prospects (from fixtures)
    Prospect.destroy_all

    # Create a suppressed prospect last updated 6 month ago
    create_suppressed_prospect(last_update: 6.months.ago)

    assert_difference ['Prospect.count', 'Resume.count', 'resume_file_count'], -1 do
      with_captured_stdout do
        Rake::Task['db:purge_suppressed_prospects'].invoke
      end
    end
  end

  test 'newly suppressed prospect is not purged' do
    # Destroy all existing prospects (from fixtures)
    Prospect.destroy_all

    # Create a suppressed prospect that was just updated
    create_suppressed_prospect(last_update: 1.second.ago)

    assert_no_difference ['Prospect.count', 'Resume.count', 'resume_file_count'] do
      with_captured_stdout do
        Rake::Task['db:purge_suppressed_prospects'].invoke
      end
    end
  end

  test 'mixture of suppressed and active records' do
    # Destroy all existing prospects (from fixtures)
    Prospect.destroy_all

    new_active = create_active_prospect(last_update: 1.second.ago)
    old_active = create_active_prospect(last_update: 2.years.ago)

    new_suppressed = create_suppressed_prospect(last_update: 1.second.ago)
    create_suppressed_prospect(last_update: 6.months.ago)
    create_suppressed_prospect(last_update: 2.years.ago)

    assert_equal 5, Prospect.count
    assert_equal 5, Resume.count

    assert_difference ['Prospect.count', 'Resume.count', 'resume_file_count'], -2 do
      with_captured_stdout do
        Rake::Task['db:purge_suppressed_prospects'].invoke
      end
    end

    existing_prospect_ids = Prospect.all.map(&:id)
    assert_equal 3, existing_prospect_ids.count
    assert_same_elements [new_active.id, old_active.id, new_suppressed.id], existing_prospect_ids
  end

  def create_active_prospect(last_update: nil)
    prospect_creator = SampleProspectCreator.new
    prospect = prospect_creator.create(require_resume: true)
    prospect.updated_at = last_update unless last_update.nil?
    prospect.save!
    prospect
  end

  def create_suppressed_prospect(last_update: nil)
    prospect_creator = SampleProspectCreator.new
    prospect = prospect_creator.create(require_resume: true)
    prospect.updated_at = last_update unless last_update.nil?
    prospect.suppressed = true
    prospect.save!
    prospect
  end

  def resume_file_count
    Dir.glob("#{RESUME_STORAGE_DIR}/**/*").select { |e| File.file? e }.count
  end
end
