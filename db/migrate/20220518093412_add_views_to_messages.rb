class AddViewsToMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :views, :integer, default: 0
  end
end
