class CreateGrades < ActiveRecord::Migration[8.0]
  def change
    create_table :grades do |t|
      t.references :student_class_subject, null: false, foreign_key: true
      t.references :grade_type, null: false, foreign_key: true
      t.decimal :score, precision: 5, scale: 2, null: false
      t.text :note
      t.references :graded_by, null: false, foreign_key: { to_table: :teachers }
      t.datetime :graded_at, default: -> { 'CURRENT_TIMESTAMP' }

      t.timestamps
    end
    
    add_index :grades, [:student_class_subject_id, :grade_type_id], unique: true, name: 'idx_student_grade_type_unique'
    add_index :grades, :graded_by_id
  end
end
