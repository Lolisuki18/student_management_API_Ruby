class CreateStudents < ActiveRecord::Migration[8.0]
  def change
    create_table :students do |t|
      t.references :user, null: false, foreign_key: true
      t.string :student_code, null: false
      t.string :full_name, null: false
      t.date :date_of_birth
      t.string :gender
      t.string :phone
      t.text :address
      t.references :major, null: false, foreign_key: true
      t.integer :enrollment_year
      t.boolean :status, default: true

      t.timestamps
    end
    
    add_index :students, :student_code, unique: true
    add_index :students, :enrollment_year
  end
end
