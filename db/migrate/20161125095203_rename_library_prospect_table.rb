class RenameLibraryProspectTable < ActiveRecord::Migration
  def change                            
    rename_table :library_preferences, :libraries_prospects 
  end
end
