class CreateOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :order_items do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true
      t.references :menu_item, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1
      t.decimal :unit_price, null: false, precision: 12, scale: 2
      t.string :notes
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
