class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.references :dining_table, null: true, foreign_key: true
      t.references :cash_session, null: true, foreign_key: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.references :discount, null: true, foreign_key: true
      t.string :order_number, null: false
      t.integer :order_type, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.decimal :subtotal, null: false, precision: 12, scale: 2, default: 0
      t.decimal :discount_amount, null: false, precision: 12, scale: 2, default: 0
      t.decimal :total, null: false, precision: 12, scale: 2, default: 0
      t.text :notes

      t.timestamps
    end

    add_index :orders, [ :restaurant_id, :order_number ], unique: true
  end
end
