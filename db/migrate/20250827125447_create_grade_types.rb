class CreateGradeTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :grade_types do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.decimal :weight, precision: 5, scale: 2, null: false
      t.text :description
      t.boolean :status, default: true

      t.timestamps
    end
    
    add_index :grade_types, :code, unique: true
  end
end
