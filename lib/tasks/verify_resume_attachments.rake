namespace :db do
  desc 'Verify that the file attachments for all known Resumes can be found'
  task verify_resume_attachments: :environment do
    RESUME_STORAGE_DIR = 'resumes'

    resumes_in_storage = Dir.glob("#{RESUME_STORAGE_DIR}/**/*").select { |e| File.file? e }.map(&File.method(:realpath))
    puts "Found #{resumes_in_storage.count} resume files in '#{RESUME_STORAGE_DIR}' storage directory"

    resume_file_attachments = Resume.all.map(&:file).map(&:path)
    puts "Found #{resume_file_attachments.count} resume file attachments in database."

    missing_files = resume_file_attachments - resumes_in_storage
    orphaned_files = resumes_in_storage - resume_file_attachments

    issues_found = false

    puts "\n"
    if missing_files.count == 0
      puts "All resume file attachments found."
    else
      issues_found = true
      puts "There are #{missing_files.count} missing resume files."
      missing_files.each do |mf|
        puts "\t#{mf}"
      end
    end

    puts "\n"
    if orphaned_files.count == 0
      puts "No orphaned resume files found."
    else
      issues_found = true
      puts "There are #{orphaned_files.count} orphaned resume files (files without an associated Resume record in the database)"
      orphaned_files.each do |of|
        puts "\t#{of}"
      end
    end

    if issues_found
      puts "\nFAILURE: Issues were found."
    else
      puts "\nSUCCESS: No issues were found."
    end
  end
end