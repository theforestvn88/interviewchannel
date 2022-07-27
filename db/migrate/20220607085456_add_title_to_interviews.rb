class AddTitleToInterviews < ActiveRecord::Migration[7.0]
  def change
    add_column :interviews, :title, :string
  end
end
