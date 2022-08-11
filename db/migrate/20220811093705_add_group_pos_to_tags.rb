class AddGroupPosToTags < ActiveRecord::Migration[7.0]
  def change
    add_column :tags, :group, :string, null: false, default: "others"
    add_column :tags, :pos, :integer, null: false, default: 1
  end
end
