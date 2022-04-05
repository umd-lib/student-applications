class DropPaperclipGemColumnsInResumes < ActiveRecord::Migration[6.1]
  def change
    remove_column :resumes, :file_file_name
    remove_column :resumes, :file_content_type
    remove_column :resumes, :file_file_size
    remove_column :resumes, :file_updated_at
  end
end
