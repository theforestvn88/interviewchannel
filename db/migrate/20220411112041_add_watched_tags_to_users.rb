class AddWatchedTagsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :watch_tags, :text
  end
end
