class CreateReplies < ActiveRecord::Migration[7.0]
  def change
    create_table :replies do |t|
      t.references :applying, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :content, limit: 150

      t.timestamps
    end
  end
end
