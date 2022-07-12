class CreateEngagings < ActiveRecord::Migration[7.0]
  def change
    create_table :engagings do |t|
      t.references :applying, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps

      t.index [:applying_id, :user_id], unique: true
    end
  end
end
