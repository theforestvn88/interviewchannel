class AddApplyingsCountToMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :applyings_count, :integer
  end
end
