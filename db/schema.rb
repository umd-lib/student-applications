# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161125095203) do

  create_table "addresses", force: :cascade do |t|
    t.string  "street_address_1"
    t.string  "street_address_2"
    t.string  "city"
    t.string  "state"
    t.string  "postal_code"
    t.string  "country"
    t.integer "address_type",     default: 1, null: false
    t.integer "prospect_id"
  end

  add_index "addresses", ["prospect_id"], name: "index_addresses_on_prospect_id"

  create_table "available_times", force: :cascade do |t|
    t.integer "prospect_id"
    t.integer "day",         default: 0, null: false
    t.integer "time",        default: 0, null: false
  end

  add_index "available_times", ["prospect_id"], name: "index_available_times_on_prospect_id"

  create_table "libraries", force: :cascade do |t|
    t.string "name"
  end

  create_table "libraries_prospects", force: :cascade do |t|
    t.integer "prospect_id"
    t.integer "library_id"
  end

  add_index "libraries_prospects", ["library_id"], name: "index_libraries_prospects_on_library_id"
  add_index "libraries_prospects", ["prospect_id"], name: "index_libraries_prospects_on_prospect_id"

  create_table "phone_numbers", force: :cascade do |t|
    t.string  "number"
    t.integer "phone_type",  default: 0, null: false
    t.integer "prospect_id"
  end

  add_index "phone_numbers", ["prospect_id"], name: "index_phone_numbers_on_prospect_id"

  create_table "prospects", force: :cascade do |t|
    t.string   "directory_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "source_from"
    t.boolean  "in_federal_study",                         null: false
    t.string   "email"
    t.string   "family_member"
    t.integer  "class_status",             default: 0,     null: false
    t.string   "major"
    t.integer  "graduation_year",          default: 0,     null: false
    t.integer  "number_of_hours"
    t.boolean  "hired",                    default: false, null: false
    t.boolean  "suppress",                 default: false, null: false
    t.text     "additional_comments"
    t.text     "hr_comments"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "available_hours_per_week", default: 0,     null: false
    t.integer  "available_times_count",    default: 0,     null: false
    t.integer  "resume_id"
  end

  add_index "prospects", ["resume_id"], name: "index_prospects_on_resume_id"

  create_table "prospects_skills", force: :cascade do |t|
    t.integer "prospect_id"
    t.integer "skill_id"
  end

  add_index "prospects_skills", ["prospect_id"], name: "index_prospects_skills_on_prospect_id"
  add_index "prospects_skills", ["skill_id"], name: "index_prospects_skills_on_skill_id"

  create_table "resumes", force: :cascade do |t|
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
  end

  create_table "skills", force: :cascade do |t|
    t.string  "name"
    t.boolean "promoted", default: false
  end

  create_table "work_experiences", force: :cascade do |t|
    t.string  "name"
    t.integer "prospect_id"
    t.string  "dates_of_employment"
    t.string  "location"
    t.text    "duties"
    t.boolean "library_related"
  end

  add_index "work_experiences", ["prospect_id"], name: "index_work_experiences_on_prospect_id"

end
