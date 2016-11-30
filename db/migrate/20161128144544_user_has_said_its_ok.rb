class UserHasSaidItsOk < ActiveRecord::Migration
  def change
    add_column :prospects, :user_signature, :string
  end
end
