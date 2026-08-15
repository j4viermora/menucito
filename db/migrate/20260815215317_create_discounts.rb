class CreateDiscounts < ActiveRecord::Migration[8.1]
  def change
    create_table :discounts do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :kind, null: false, default: 0
      t.decimal :value, null: false, precision: 12, scale: 2
      t.boolean :active, null: false, default: true
      t.boolean :requires_authorization, null: false, default: false
      t.datetime :starts_at
      t.datetime :ends_at

      t.timestamps
    end
  end
end
