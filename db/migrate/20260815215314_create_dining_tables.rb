class CreateDiningTables < ActiveRecord::Migration[8.1]
  def change
    create_table :dining_tables do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.string :code, null: false
      t.integer :capacity, null: false, default: 4
      t.integer :status, null: false, default: 0
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :dining_tables, [ :restaurant_id, :code ], unique: true
  end
end
