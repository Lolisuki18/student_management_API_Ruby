class AddStudyClassToStudents < ActiveRecord::Migration[8.0]
  def change
    add_reference :students, :study_class, null: true, foreign_key: { to_table: :classes }
  end
end
