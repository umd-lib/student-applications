class AddSuppress < ActiveRecord::Migration[4.2]
  def change
     add_column :prospects, :suppressed, :boolean, default: false
  end
end
