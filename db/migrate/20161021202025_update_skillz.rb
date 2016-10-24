class UpdateSkillz < ActiveRecord::Migration
  def change
    add_column :skills, :promoted, :boolean
    rename_column :prospects_skills, :skills_id, :skill_id 
    add_index :prospects_skills, :skill_id, name: "index_prospects_skills_on_skill_id"
  end
end
