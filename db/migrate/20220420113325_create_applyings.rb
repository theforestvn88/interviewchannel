class CreateApplyings < ActiveRecord::Migration[7.0]
  def change
    create_table :applyings do |t|
      t.references :message, null: false, foreign_key: true
      t.belongs_to :candidate, null: false, foreign_key: {to_table: :users}
      t.belongs_to :interviewer, null: false, foreign_key: {to_table: :users}
      t.text :intro, limit: 500

      t.timestamps

      t.index [:message_id, :candidate_id], unique: true
    end
  end
end
