class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.string :channel
      t.text :content, limit: 500
      t.datetime :expired_at
      t.belongs_to :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
