class AddSuggestTrigramToUsers < ActiveRecord::Migration[7.0]
  def change
    enable_extension :pg_trgm

    add_column :users, :suggest_trgm, :string, null: false, default: ""
    add_index :users, :suggest_trgm, opclass: :gin_trgm_ops, using: :gin
  end
end
