class AddAddressesTable < ActiveRecord::Migration
  def change
    
    %i( local_address local_phone perm_address perm_phone ).each do |col|
      remove_column :prospects, col, :string
    end
    
    create_table :addresses do |t|
      t.string :street_address_1
      t.string :street_address_2
      t.string :city
      t.string :state
      t.string :postal_code
      t.string :country
      t.column :address_type, :integer, default: 1, null: false

      t.references :prospect, index: true, foreign_key: true
    end

    create_table :phone_numbers do |t|
      t.string :number
      t.string :type
      t.references :prospect, index: true, foreign_key: true
    end
  
  
  end
end
