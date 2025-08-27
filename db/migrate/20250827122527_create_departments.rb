class CreateDepartments < ActiveRecord::Migration[8.0]
  def change
    create_table :departments do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.text :description
      t.integer :head_teacher_id
      t.boolean :status, default: true

      t.timestamps
    end
    
    add_index :departments, :code, unique: true
    add_index :departments, :head_teacher_id
  end
end
