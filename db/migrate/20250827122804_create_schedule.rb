class CreateSchedule < ActiveRecord::Migration[8.0]
  def change
    create_table :schedules do |t|
      t.references :class_subject, null: false, foreign_key: true
      t.integer :day_of_week, null: false # 1-7 (Monday-Sunday)
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.references :room, null: false, foreign_key: true
      t.string :week_type, default: 'all' # 'all', 'odd', 'even'
      t.date :effective_date
      t.boolean :status, default: true

      t.timestamps
    end
    
    add_index :schedules, [:class_subject_id, :day_of_week, :start_time], name: 'idx_schedule_unique'
    add_index :schedules, [:day_of_week, :start_time, :room_id]
  end
end
