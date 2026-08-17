class KitchenController < AuthenticatedController
  before_action { require_permission!(:kitchen_access?) }

  def index
    @order_items = OrderItem.kitchen_visible
      .includes(:menu_item, order: :dining_table)
      .order(:created_at)
      .group_by(&:order)
  end

  def serve
    item = OrderItem.find(params[:id])
    item.update!(status: :served, served_at: Time.current)
    KitchenBroadcast.sync(current_restaurant)
    redirect_to kitchen_path
  end

  def history
    @order_items = OrderItem.where(status: :served)
      .includes(:menu_item, order: :dining_table)
      .order(served_at: :desc)
      .limit(100)
  end
end
