class AddChannelIndexToMessages < ActiveRecord::Migration[7.0]
  def change
    add_index :messages, :channel, opclass: :gist_trgm_ops, using: :gist
  end
end
