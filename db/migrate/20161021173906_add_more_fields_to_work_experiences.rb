class AddMoreFieldsToWorkExperiences < ActiveRecord::Migration[4.2]
  def change
    add_column :work_experiences, :dates_of_employment, :string
    add_column :work_experiences, :location, :string
    add_column :work_experiences, :duties, :text
    add_column :work_experiences, :library_related, :boolean
  end
end
