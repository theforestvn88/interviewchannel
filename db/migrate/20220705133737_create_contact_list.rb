class CreateContactList < ActiveRecord::Migration[7.0]
  def change
    create_table :contacts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :friend, null: false, foreign_key: {to_table: :users}, index: false

      t.timestamps
    end
  end
end
