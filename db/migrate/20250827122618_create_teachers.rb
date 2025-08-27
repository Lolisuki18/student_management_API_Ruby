class CreateTeachers < ActiveRecord::Migration[8.0]
  def change
    create_table :teachers do |t|
      t.references :user, null: false, foreign_key: true
      t.string :teacher_code, null: false
      t.string :full_name, null: false
      t.string :phone
      t.string :email
      t.references :department, null: false, foreign_key: true
      t.string :position
      t.date :hire_date
      t.boolean :status, default: true

      t.timestamps
    end
    
    add_index :teachers, :teacher_code, unique: true
    add_index :teachers, :email, unique: true
  end
end
