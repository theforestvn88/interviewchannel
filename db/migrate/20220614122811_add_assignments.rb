class AddAssignments < ActiveRecord::Migration[7.0]
  def change
    create_table :assignments do |t|
      t.references :interview, null: false
      t.references :user, null: false

      t.timestamps
    end
  end
end
