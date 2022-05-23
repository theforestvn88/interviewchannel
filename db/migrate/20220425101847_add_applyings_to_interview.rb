class AddApplyingsToInterview < ActiveRecord::Migration[7.0]
  def change
    add_reference :interviews, :applying, null: true, foreign_key: true
  end
end
