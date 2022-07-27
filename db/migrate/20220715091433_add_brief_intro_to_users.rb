class AddBriefIntroToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :brief_intro, :string, null: true
  end
end
