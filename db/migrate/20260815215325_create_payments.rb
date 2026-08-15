class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true
      t.references :cash_session, null: true, foreign_key: true
      t.integer :method, null: false, default: 0
      t.decimal :amount, null: false, precision: 12, scale: 2

      t.timestamps
    end
  end
end
