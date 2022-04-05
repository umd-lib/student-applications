# frozen_string_literal: true

# rails runner copy_resumes_to_active_storage_directory.rb

ActiveStorage::Attachment.find_each do |attachment|
  name = attachment.name

  source = attachment.record.send(name).path

  dest_dir = File.join(
    ActiveStorage::Blob.service.root,
    attachment.blob.key.first(2),
    attachment.blob.key.first(4).last(2)
  )
  dest = File.join(dest_dir, attachment.blob.key)

  FileUtils.mkdir_p(dest_dir)
  puts "Moving #{source} to #{dest}"
  FileUtils.cp(source, dest)
end
