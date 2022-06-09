class AddEnumStateToInterviews < ActiveRecord::Migration[7.0]
  def up
    create_enum :interview_state, ["wait", "in_process", "finish", "canceled"]

    change_table :interviews do |t|
      t.enum :state, enum_type: "interview_state", default: "wait", null: false
    end
  end

  def down
    remove_column :interviews, :state
    execute <<-SQL
      DROP TYPE interview_state;
    SQL
  end
end
