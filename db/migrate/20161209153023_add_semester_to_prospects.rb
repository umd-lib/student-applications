class AddSemesterToProspects < ActiveRecord::Migration[4.2]
  def change
    add_column :prospects, :semester, :integer
  end
end
