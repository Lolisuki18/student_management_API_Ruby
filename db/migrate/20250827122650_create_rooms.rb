class CreateRooms < ActiveRecord::Migration[8.0]
  def change
    create_table :rooms do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.integer :capacity, default: 40
      t.string :building
      t.string :floor
      t.text :equipment
      t.string :room_type, default: 'classroom'
      t.boolean :status, default: true

      t.timestamps
    end
    
    add_index :rooms, :code, unique: true
    add_index :rooms, [:building, :floor]
  end
end
