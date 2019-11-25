class AddAttachmentResumeToProspects < ActiveRecord::Migration[4.2]
  def change

    create_table :resumes do |t|
      t.attachment :file
    end

    change_table :prospects do |t|
      t.references :resume, index: true, foreign_key: true
    end

  end
end
