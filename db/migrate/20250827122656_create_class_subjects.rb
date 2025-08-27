class CreateClassSubjects < ActiveRecord::Migration[8.0]
  def change
    create_table :class_subjects do |t|
      t.references :subject, null: false, foreign_key: true
      t.references :teacher, null: false, foreign_key: true
      t.string :class_code, null: false
      t.string :academic_year, null: false
      t.integer :semester, null: false
      t.integer :max_students, default: 40
      t.integer :current_students, default: 0
      t.references :room, null: true, foreign_key: true
      t.boolean :status, default: true

      t.timestamps
    end
    
    add_index :class_subjects, :class_code, unique: true
    add_index :class_subjects, [:academic_year, :semester]
    add_index :class_subjects, [:subject_id, :teacher_id]
  end
end
