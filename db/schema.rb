# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_03_30_144713) do

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.integer "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.string "street_address_1"
    t.string "street_address_2"
    t.string "city"
    t.string "state"
    t.string "postal_code"
    t.string "country"
    t.integer "address_type", default: 1, null: false
    t.integer "prospect_id"
    t.index ["prospect_id"], name: "index_addresses_on_prospect_id"
  end

  create_table "available_times", force: :cascade do |t|
    t.integer "prospect_id"
    t.integer "day", default: 0, null: false
    t.integer "time", default: 0, null: false
    t.index ["prospect_id"], name: "index_available_times_on_prospect_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "enumerations", force: :cascade do |t|
    t.string "value", null: false
    t.integer "list", default: 0, null: false
    t.boolean "active", default: true
    t.integer "position", default: 0, null: false
  end

  create_table "phone_numbers", force: :cascade do |t|
    t.string "number"
    t.integer "phone_type", default: 0, null: false
    t.integer "prospect_id"
    t.index ["prospect_id"], name: "index_phone_numbers_on_prospect_id"
  end

  create_table "prospects", force: :cascade do |t|
    t.string "directory_id"
    t.string "first_name"
    t.string "last_name"
    t.string "source_from"
    t.boolean "in_federal_study", null: false
    t.string "email"
    t.string "family_member"
    t.string "major"
    t.integer "number_of_hours"
    t.boolean "hired", default: false, null: false
    t.boolean "suppress", default: false, null: false
    t.text "additional_comments"
    t.text "hr_comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "available_hours_per_week", default: 0, null: false
    t.integer "available_times_count", default: 0, null: false
    t.integer "resume_id"
    t.string "user_signature"
    t.integer "semester"
    t.boolean "suppressed", default: false
    t.index ["resume_id"], name: "index_prospects_on_resume_id"
  end

  create_table "prospects_enumerations", id: false, force: :cascade do |t|
    t.integer "prospect_id"
    t.integer "enumeration_id"
    t.index ["enumeration_id"], name: "index_prospects_enumerations_on_enumeration_id"
    t.index ["prospect_id"], name: "index_prospects_enumerations_on_prospect_id"
  end

  create_table "prospects_skills", force: :cascade do |t|
    t.integer "prospect_id"
    t.integer "skill_id"
    t.index ["prospect_id"], name: "index_prospects_skills_on_prospect_id"
    t.index ["skill_id"], name: "index_prospects_skills_on_skill_id"
  end

  create_table "resumes", force: :cascade do |t|
    t.string "file_file_name"
    t.string "file_content_type"
    t.integer "file_file_size"
    t.datetime "file_updated_at"
    t.string "upload_session_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.string "cas_ticket"
    t.text "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["cas_ticket"], name: "index_sessions_on_cas_ticket"
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "skills", force: :cascade do |t|
    t.string "name"
    t.boolean "promoted", default: false
  end

  create_table "users", force: :cascade do |t|
    t.string "cas_directory_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false
  end

  create_table "work_experiences", force: :cascade do |t|
    t.string "name"
    t.integer "prospect_id"
    t.string "dates_of_employment"
    t.string "location"
    t.text "duties"
    t.boolean "library_related"
    t.string "position_title"
    t.index ["prospect_id"], name: "index_work_experiences_on_prospect_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "prospects"
  add_foreign_key "phone_numbers", "prospects"
  add_foreign_key "prospects_skills", "prospects"
  add_foreign_key "prospects_skills", "skills"
  add_foreign_key "work_experiences", "prospects"
end
