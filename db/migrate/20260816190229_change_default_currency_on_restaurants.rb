class ChangeDefaultCurrencyOnRestaurants < ActiveRecord::Migration[8.1]
  def change
    change_column_default :restaurants, :currency, from: "COP", to: "USD"
  end
end
