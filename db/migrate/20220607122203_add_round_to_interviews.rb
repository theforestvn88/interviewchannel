class AddRoundToInterviews < ActiveRecord::Migration[7.0]
  def change
    add_column :interviews, :round, :integer, default: 1
    add_reference :interviews, :head, null: true, foreign_key: {to_table: :interviews}
  end
end
