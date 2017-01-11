class AddSessionToResume < ActiveRecord::Migration
  def change
     add_column :resumes, :upload_session_id, :string
  end
end
