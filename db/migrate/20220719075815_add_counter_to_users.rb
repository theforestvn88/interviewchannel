class AddCounterToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :messages_count, :integer, default: 0, null: false
    add_column :users, :interviews_count, :integer, default: 0, null: false
  end
end
