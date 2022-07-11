class AddMilestoneToReplies < ActiveRecord::Migration[7.0]
  def up
    create_enum :stone_type, ["comment", "interview", "assignment", "apply"]
    
    change_table :replies do |t| 
      t.enum :milestone, enum_type: "stone_type", default: "comment", null: false
    end
  end

  def down
    remove_column :replies, :milestone
    execute <<-SQL
      DROP TYPE IF EXISTS stone_type;
    SQL
  end
end
