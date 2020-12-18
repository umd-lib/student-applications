class AddNameOfEmployer < ActiveRecord::Migration[4.2]
  def change
     add_column :work_experiences, :position_title, :string
  end
end
