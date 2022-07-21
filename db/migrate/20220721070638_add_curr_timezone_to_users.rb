class AddCurrTimezoneToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :curr_timezone, :string, default: "UTC", null: false
  end
end
