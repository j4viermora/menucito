class AddWaitersCanCollectPaymentToRestaurants < ActiveRecord::Migration[8.1]
  def change
    add_column :restaurants, :waiters_can_collect_payment, :boolean, default: false, null: false
  end
end
