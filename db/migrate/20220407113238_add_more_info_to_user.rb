class AddMoreInfoToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :image, :string
    add_column :users, :github, :string
  end
end
