class CreateStudentClassSubjects < ActiveRecord::Migration[8.0]
  def change
    create_table :student_class_subjects do |t|
      t.references :student, null: false, foreign_key: true
      t.references :class_subject, null: false, foreign_key: true
      t.date :enrollment_date, default: -> { 'CURRENT_TIMESTAMP' }
      t.boolean :status, default: true

      t.timestamps
    end
    
    add_index :student_class_subjects, [:student_id, :class_subject_id], unique: true, name: 'idx_student_class_subject_unique'
  end
end
