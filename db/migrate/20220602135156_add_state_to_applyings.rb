class AddStateToApplyings < ActiveRecord::Migration[7.0]
  def change
    add_column :applyings, :open, :boolean, default: true
  end
end
