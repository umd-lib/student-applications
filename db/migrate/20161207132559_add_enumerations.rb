class AddEnumerations < ActiveRecord::Migration
  def change
    
    remove_column :prospects, :graduation_year    
    remove_column :prospects, :class_status  

    drop_table :libraries_prospects
    drop_table :libraries
    
    create_table :enumerations do |t|
      t.column :value, :string, null: false
      t.column :list, :integer, default: 0, null: false
      t.column :active, :boolean, default: true 
      t.column :position, :integer, default: 0, null: false
    end

    create_table :prospects_enumerations, id: false do |t|
      t.belongs_to :prospect, index: true
      t.belongs_to :enumeration, index: true
    end
  
  end
end
