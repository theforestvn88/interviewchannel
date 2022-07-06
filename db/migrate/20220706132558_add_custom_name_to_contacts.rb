class AddCustomNameToContacts < ActiveRecord::Migration[7.0]
  def change
    add_column :contacts, :custom_name, :string, null: false
  end
end
