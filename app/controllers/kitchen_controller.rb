class KitchenController < AuthenticatedController
  before_action { require_permission!(:kitchen_access?) }

  def index
    @order_items = OrderItem.where(status: [ :pending, :printed ])
      .joins(:order).where(orders: { status: [ :open, :sent_to_kitchen, :served ] })
      .includes(:menu_item, order: :dining_table)
      .order(:created_at)
      .group_by(&:order)
  end

  def serve
    item = OrderItem.find(params[:id])
    item.update!(status: :served)
    redirect_to kitchen_path
  end
end
