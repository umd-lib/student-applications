class AddSuppress < ActiveRecord::Migration
  def change
     add_column :prospects, :suppressed, :boolean, default: false
  end
end
