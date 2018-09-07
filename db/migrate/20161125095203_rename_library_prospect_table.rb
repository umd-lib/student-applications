class RenameLibraryProspectTable < ActiveRecord::Migration[4.2]
  def change
    rename_table :library_preferences, :libraries_prospects
  end
end
