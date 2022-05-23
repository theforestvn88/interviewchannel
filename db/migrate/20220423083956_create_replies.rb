class CreateReplies < ActiveRecord::Migration[7.0]
  def change
    create_table :replies do |t|
      t.references :applying, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :content, limit: 500

      t.timestamps
    end
  end
end
