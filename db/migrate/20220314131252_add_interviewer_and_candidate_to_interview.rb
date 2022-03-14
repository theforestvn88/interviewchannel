class AddInterviewerAndCandidateToInterview < ActiveRecord::Migration[7.0]
  def change
    add_reference :interviews, :interviewer, null: false, foreign_key: {to_table: :users}
    add_reference :interviews, :candidate, null: true, foreign_key: {to_table: :users}
  end
end
