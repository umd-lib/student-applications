class AddSemesterToProspects < ActiveRecord::Migration
  def change
    add_column :prospects, :semester, :integer
  end
end
