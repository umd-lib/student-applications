require "./lib/tasks/sample_prospect_creator"

namespace :db do
  desc "Drop, create, migrate, seed and populate sample data"
  task reset_with_sample_data: [:drop, :create, :migrate, :seed, :populate_sample_data] do
    puts "Ready to go!"
  end

  desc "Populates the database with sample data"
  task populate_sample_data: :environment do
    prospect_builder = SampleProspectCreator.new
    700.times do |index|
      prospect_builder.create(require_resume: false)
    end
  end
end
