class AddMilestoneToReplies < ActiveRecord::Migration[7.0]
  def change
    add_column :replies, :milestone, :boolean, default: false
  end
end
