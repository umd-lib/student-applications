class AddNumberOfHours < ActiveRecord::Migration[4.2]
  def change

    add_column :prospects, :available_hours_per_week, :integer, default: 0, null: false
    add_column :prospects, :available_times_count, :integer, default: 0, null: false

  end
end
