class RemoveInterviewerFromInterviews < ActiveRecord::Migration[7.0]
  def change
    remove_column :interviews, :interviewer_id, :bigint
  end
end
