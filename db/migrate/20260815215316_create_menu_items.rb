class CreateMenuItems < ActiveRecord::Migration[8.1]
  def change
    create_table :menu_items do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.references :menu_category, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.decimal :price, null: false, precision: 12, scale: 2
      t.boolean :available, null: false, default: true
      t.integer :position, null: false, default: 0

      t.timestamps
    end
  end
end
