class AddAutoReplyToMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :auto_reply_enable, :boolean, default: false
    add_column :messages, :auto_reply, :text, null: true
  end
end
