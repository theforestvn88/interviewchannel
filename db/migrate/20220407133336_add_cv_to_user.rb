class AddCvToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :cv, :text
  end
end
