class CreateRestaurants < ActiveRecord::Migration[8.1]
  def change
    create_table :restaurants do |t|
      t.string :name, null: false
      t.string :subdomain, null: false
      t.string :slug, null: false
      t.string :timezone, null: false, default: "America/Bogota"
      t.string :currency, null: false, default: "COP"
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :restaurants, :subdomain, unique: true
    add_index :restaurants, :slug, unique: true
  end
end
