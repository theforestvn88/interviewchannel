class CreateNotes < ActiveRecord::Migration[7.0]
  def change
    create_table :notes do |t|
      t.text :content, null: false
      t.string :cc
      t.references :user, null: false, foreign_key: true
      t.references :interview, null: false, foreign_key: true

      t.timestamps
    end
  end
end
