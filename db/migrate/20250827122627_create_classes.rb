class CreateClasses < ActiveRecord::Migration[8.0]
  def change
    create_table :classes do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.references :major, null: false, foreign_key: true
      t.string :academic_year, null: false
      t.integer :semester, null: false
      t.references :homeroom_teacher, null: true, foreign_key: { to_table: :teachers }
      t.integer :max_students, default: 40
      t.integer :current_students, default: 0
      t.boolean :status, default: true

      t.timestamps
    end
    
    add_index :classes, :code, unique: true
    add_index :classes, [:academic_year, :semester]
  end
end
