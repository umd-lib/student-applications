class UpdateSkillz < ActiveRecord::Migration
  def change
     add_column :skills, :promoted, :boolean, default: false
  end
end
