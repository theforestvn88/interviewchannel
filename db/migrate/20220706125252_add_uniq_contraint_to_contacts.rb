class AddUniqContraintToContacts < ActiveRecord::Migration[7.0]
  def change
    add_index :contacts, [:user_id, :friend_id], unique: true
  end
end
