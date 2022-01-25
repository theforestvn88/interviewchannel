class CreateInterviews < ActiveRecord::Migration[7.0]
  def change
    create_table :interviews do |t|
      t.string :note
      t.datetime :start_time
      t.datetime :end_time
      t.text :code
      t.boolean :result

      t.timestamps
    end
  end
end
