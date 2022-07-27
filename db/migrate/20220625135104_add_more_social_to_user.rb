class AddMoreSocialToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :social, :json
  end
end
