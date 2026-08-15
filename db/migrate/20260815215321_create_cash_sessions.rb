class CreateCashSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :cash_sessions do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.references :opened_by, null: false, foreign_key: { to_table: :users }
      t.references :closed_by, null: true, foreign_key: { to_table: :users }
      t.integer :status, null: false, default: 0
      t.decimal :opening_amount, null: false, precision: 12, scale: 2, default: 0
      t.decimal :counted_amount, precision: 12, scale: 2
      t.decimal :expected_amount, precision: 12, scale: 2
      t.decimal :difference_amount, precision: 12, scale: 2
      t.datetime :opened_at, null: false
      t.datetime :closed_at
      t.text :notes

      t.timestamps
    end

    add_index :cash_sessions, [ :restaurant_id, :status ]
  end
end
