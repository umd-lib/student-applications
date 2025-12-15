# frozen_string_literal: true

# rails runner copy_data_to_active_storage_tables.rb

def key(_instance, _attachment)
  SecureRandom.uuid
  # Alternatively:
  # instance.send("#{attachment}_file_name")
end

def checksum(attachment)
  # local files stored on disk:
  url = attachment.path
  Digest::MD5.base64digest(File.read(url))

  # remote files stored on another person's computer:
  # url = attachment.url
  # Digest::MD5.base64digest(Net::HTTP.get(URI(url)))
end

require 'open-uri'

use_sqlite = Rails.env.development? || Rails.env.test?

get_blob_id = if use_sqlite
                'LAST_INSERT_ROWID()'
else
                # Postgres
                'LASTVAL()'
end

# rubocop:disable Rails/SquishedSQLHeredocs, Layout/LineLength
if use_sqlite
  # SQLite
  active_storage_blob_statement = ActiveRecord::Base.connection.raw_connection.prepare(<<-SQL)
    INSERT INTO active_storage_blobs (
      `key`, filename, content_type, metadata, byte_size, checksum, created_at, service_name
    ) VALUES (?, ?, ?, '{}', ?, ?, ?, 'local')
  SQL

  active_storage_attachment_statement = ActiveRecord::Base.connection.raw_connection.prepare(<<-SQL)
    INSERT INTO active_storage_attachments (
      name, record_type, record_id, blob_id, created_at
    ) VALUES (?, ?, ?, #{get_blob_id}, ?)
  SQL
else
  # Postgres
  active_storage_blob_statement = ActiveRecord::Base.connection.raw_connection.prepare('active_storage_blob_statement', <<-SQL)
    INSERT INTO active_storage_blobs (
      key, filename, content_type, metadata, byte_size, checksum, created_at, service_name
    ) VALUES ($1, $2, $3, '{}', $4, $5, $6, 'local')
  SQL

  active_storage_attachment_statement = ActiveRecord::Base.connection.raw_connection.prepare('active_storage_attachment_statement', <<-SQL)
    INSERT INTO active_storage_attachments (
      name, record_type, record_id, blob_id, created_at
    ) VALUES ($1, $2, $3, #{get_blob_id}, $4)
  SQL
end
# rubocop:enable Rails/SquishedSQLHeredocs, Layout/LineLength

Rails.application.eager_load!
models = [ Resume ]
ActiveRecord::Base.transaction do # rubocop:disable Metrics/BlockLength
  models.each do |model| # rubocop:disable Metrics/BlockLength
    attachments = model.column_names.map do |c|
      Regexp.last_match(1) if c =~ /(.+)_file_name$/
    end.compact

    next if attachments.blank?

    model.find_each.each do |instance| # rubocop:disable Metrics/BlockLength
      attachments.each do |attachment| # rubocop:disable Metrics/BlockLength
        next if instance.send(attachment).path.blank?

        if use_sqlite
          # SQLite
          active_storage_blob_statement.execute(
            key(instance, attachment),
            instance.send("#{attachment}_file_name"),
            instance.send("#{attachment}_content_type"),
            instance.send("#{attachment}_file_size"),
            checksum(instance.send(attachment)),
            instance.send('file_updated_at').iso8601
          )

          active_storage_attachment_statement.execute(
            attachment,
            model.name,
            instance.id,
            instance.send('file_updated_at').iso8601
          )
        else
          # Postgres
          # See https://stackoverflow.com/a/54347809
          ActiveRecord::Base.connection.raw_connection.exec_prepared(
            'active_storage_blob_statement', [
              key(instance, attachment),
              instance.send("#{attachment}_file_name"),
              instance.send("#{attachment}_content_type"),
              instance.send("#{attachment}_file_size"),
              checksum(instance.send(attachment)),
              instance.send('file_updated_at').iso8601
            ]
          )

          ActiveRecord::Base.connection.raw_connection.exec_prepared(
            'active_storage_attachment_statement', [
              attachment,
              model.name,
              instance.id,
              instance.send('file_updated_at').iso8601
            ]
          )
        end
      end
    end
  end
end
