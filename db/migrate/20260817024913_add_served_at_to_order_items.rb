class AddServedAtToOrderItems < ActiveRecord::Migration[8.1]
  def change
    add_column :order_items, :served_at, :datetime
  end
end
