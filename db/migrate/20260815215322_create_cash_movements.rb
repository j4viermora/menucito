class CreateCashMovements < ActiveRecord::Migration[8.1]
  def change
    create_table :cash_movements do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.references :cash_session, null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.integer :kind, null: false, default: 0
      t.decimal :amount, null: false, precision: 12, scale: 2
      t.string :description, null: false

      t.timestamps
    end
  end
end
