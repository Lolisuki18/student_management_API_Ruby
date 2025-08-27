class CreateSubjects < ActiveRecord::Migration[8.0]
  def change
    create_table :subjects do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.integer :credits, null: false
      t.integer :theory_hours, default: 0
      t.integer :practice_hours, default: 0
      t.references :major, null: false, foreign_key: true
      t.integer :semester_number
      t.boolean :is_required, default: true
      t.boolean :status, default: true

      t.timestamps
    end
    
    add_index :subjects, :code, unique: true
    add_index :subjects, [:major_id, :semester_number]
  end
end
