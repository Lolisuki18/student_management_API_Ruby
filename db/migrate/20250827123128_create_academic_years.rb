class CreateAcademicYears < ActiveRecord::Migration[8.0]
  def change
    create_table :academic_years do |t|
      t.string :name, null: false # VD: "2024-2025"
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.boolean :is_current, default: false
      t.boolean :status, default: true

      t.timestamps
    end
    
    add_index :academic_years, :name, unique: true
    add_index :academic_years, :is_current
  end
end
