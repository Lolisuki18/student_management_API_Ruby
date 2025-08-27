class CreateMajors < ActiveRecord::Migration[8.0]
  def change
    create_table :majors do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.text :description
      t.integer :duration_years, default: 4
      t.references :department, null: false, foreign_key: true
      t.boolean :status, default: true

      t.timestamps
    end
    
    add_index :majors, :code, unique: true
  end
end
