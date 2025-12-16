require "csv"
# lib/tasks/add_cas_user.rake
namespace :db do
  desc "Add an admin user"
  task :add_admin_cas_user, %i[cas_directory_id full_name] => :environment do |_t, args|
    cas_directory_id = args[:cas_directory_id]

    if !User.find_by(cas_directory_id: cas_directory_id)
      User.create!(cas_directory_id: args[:cas_directory_id], name: args[:full_name], admin: true)
      puts "Admin user '#{cas_directory_id}' created!"
    else
      puts "User '#{cas_directory_id}' already exists!"
    end
  end

  desc "Add a non-admin user"
  task :add_cas_user, %i[cas_directory_id full_name] => :environment do |_t, args|
    cas_directory_id = args[:cas_directory_id]

    if !User.find_by(cas_directory_id: cas_directory_id)
      User.create!(cas_directory_id: args[:cas_directory_id], name: args[:full_name], admin: false)
      puts "User '#{cas_directory_id}' created!"
    else
      puts "User '#{cas_directory_id}' already exists!"
    end
  end

  desc "Toggle user admin"
  task :toggle_admin, [ :cas_directory_id ] => :environment do |_t, args|
    cas_directory_id = args[:cas_directory_id]

    user = User.find_by(cas_directory_id: cas_directory_id)

    if user.nil?
      puts "Cannot find user with id #{cas_directory_id}"
    else
      user.update_attribute(:admin, !user.admin)
      puts "User #{cas_directory_id} now admin: #{user.admin?}"
    end
  end

  desc "Bulk add users from CSV file"
  task :bulk_add_users, [ :csv_file ] => :environment do |_t, args|
    file = args[:csv_file]
    if !File.exist?(file)
      puts "Cannot open file at #{file}"
    else
      CSV.foreach(file) do |row|
        User.find_or_create_by!(cas_directory_id: row[1], name: row[0], admin: false)
        puts "Creating user id: #{row[1]} name: #{row[0]}"
      end
    end
  end
end
