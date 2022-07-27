class AddUniqIndexToAssignments < ActiveRecord::Migration[7.0]
  def change
    add_index :assignments, [:interview_id, :user_id], unique: true
  end
end
