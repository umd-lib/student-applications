class UpdateSkillz < ActiveRecord::Migration[4.2]
  def change
     add_column :skills, :promoted, :boolean, default: false
  end
end
