class AddSessionToResume < ActiveRecord::Migration[4.2]
  def change
     add_column :resumes, :upload_session_id, :string
  end
end
