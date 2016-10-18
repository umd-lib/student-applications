class AddProspect < ActiveRecord::Migration
  def change
    
    create_table :prospects do |t|

      t.string :directory_id  
      t.string :first_name
      t.string :last_name
      t.string :source_from
      t.boolean :in_federal_study, default: 0

      t.string :local_address
      t.string :local_phone
      t.string :perm_address
      t.string :perm_phone
      t.string :email
      t.string :family_member

      t.column :class_status, :integer, default: 0, null: false
      t.string :major

      t.column :graduation_year, :integer, default: 0, null: false
      t.integer :number_of_hours

      t.boolean :hired, default: false, null: false
      t.boolean :suppress, default: false, null: false

      t.text :additional_comments
      t.text :hr_comments
      
      t.timestamps null: false

    end
    
    create_table :libraries do |t|
      t.string :name
    end
  
    create_table :library_preferences do |t|
      t.references :prospect, index: true, foreign_key: true
      t.references :library, index: true, foreign_key: true
    end

    create_table :skills do |t|
      t.string :name
    end
    
    create_table :prospects_skills do |t|
      t.references :prospect, index: true, foreign_key: true
      t.references :skills, index: true, foreign_key: true
    end

    create_table :work_experiences do |t|
      t.string :name
      t.references :prospect, index: true, foreign_key: true
    end

    create_table :available_times do |t|
      t.datetime :start
      t.datetime :end
      t.boolean :all_day, default: false, null: false
      t.references :prospect, index: true, foreign_key: true
    end
    
    create_table :available_days do |t|
      t.column :day, :integer, default: 0, null: false
      t.references :available_time, index: true, foreign_key: true 
    end

  end
end
