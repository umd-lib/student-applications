class UserHasSaidItsOk < ActiveRecord::Migration[4.2]
  def change
    add_column :prospects, :user_signature, :string
  end
end
