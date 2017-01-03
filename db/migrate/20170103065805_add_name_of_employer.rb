class AddNameOfEmployer < ActiveRecord::Migration
  def change
     add_column :work_experiences, :position_title, :string
  end
end
