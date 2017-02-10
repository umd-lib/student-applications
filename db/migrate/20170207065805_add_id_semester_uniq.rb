class AddIdSemesterUniq < ActiveRecord::Migration
  def change
     add_index :prospects,[ :directory_id, :semester_id, :suppress ], unique: true
  end
end
