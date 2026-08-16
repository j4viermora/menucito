class OrderItemsController < AuthenticatedController
  before_action :set_order
  before_action :ensure_order_editable

  def create
    menu_item = current_restaurant.menu_items.find(params[:menu_item_id])
    quantity = params[:quantity].presence&.to_i || 1

    # Group into the current (not-yet-sent) round instead of adding a
    # duplicate line, so "send to kitchen" only ever prints what's new.
    existing = @order.order_items.pending.find_by(menu_item: menu_item)
    if existing
      existing.increment!(:quantity, quantity)
    else
      @order.order_items.create!(menu_item: menu_item, quantity: quantity)
    end

    @order.recalculate_totals!
    redirect_to dining_table_path(@order.dining_table)
  end

  def destroy
    item = @order.order_items.pending.find(params[:id])
    item.destroy
    @order.recalculate_totals!
    redirect_to dining_table_path(@order.dining_table)
  end

  private

  def set_order
    @order = current_restaurant.orders.find(params[:order_id])
  end

  def ensure_order_editable
    return unless @order.paid? || @order.cancelled?
    redirect_to dining_table_path(@order.dining_table), alert: "Este pedido ya está cerrado."
  end
end
