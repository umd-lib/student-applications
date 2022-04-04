namespace :db do
  desc 'Purge all soft-deleted prospects and associated resumes'
  task purge_suppressed_prospects: :environment do
    # Purge suppressed records that were last updated 7 days ago
    updated_before = 7.days.ago
    puts "Purging suppressed prospects not updated since: #{updated_before}"

    to_purge = Prospect.where(suppressed: true).where('updated_at < ?', updated_before)
    puts "Found #{to_purge.count} records to purge."

    starting_prospect_count = Prospect.count

    puts "Purging prospects"
    to_purge.destroy_all

    ending_prospect_count = Prospect.count
    num_prospects_purged = starting_prospect_count - ending_prospect_count

    puts "Purged #{num_prospects_purged} prospects"
    puts "SUCCESS"
  end
end
