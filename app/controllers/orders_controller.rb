class OrdersController < AuthenticatedController
  before_action :set_order

  layout false, only: [ :comanda ]

  def show
  end

  def update
    if @order.update(order_params)
      @order.recalculate_totals!
      redirect_to (@order.dining_table ? dining_table_path(@order.dining_table) : order_path(@order)), notice: "Pedido actualizado."
    else
      render :show, status: :unprocessable_entity
    end
  end

  def comanda
    @order_items = if params[:only].present?
      @order.order_items.where(id: params[:only].split(","))
    else
      @order.order_items
    end.includes(:menu_item)
  end

  def send_to_kitchen
    pending_ids = @order.order_items.pending.pluck(:id)

    if pending_ids.empty?
      redirect_to (@order.dining_table ? dining_table_path(@order.dining_table) : @order), alert: "No hay platos nuevos para enviar a cocina."
      return
    end

    @order.order_items.where(id: pending_ids).update_all(status: :printed)
    @order.update!(status: :sent_to_kitchen) if @order.open?
    redirect_to comanda_order_path(@order, only: pending_ids.join(","))
  end

  def pay
    ActiveRecord::Base.transaction do
      @order.payments.create!(
        restaurant: current_restaurant,
        cash_session: current_restaurant.current_cash_session,
        method: params[:payment_method].presence || :cash,
        amount: @order.total
      )
      @order.update!(status: :paid)
      @order.dining_table&.update!(status: :free)
    end
    redirect_to @order, notice: "Pedido pagado."
  end

  def cancel
    @order.update!(status: :cancelled)
    @order.dining_table&.update(status: :free)
    redirect_to dining_tables_path, notice: "Pedido cancelado."
  end

  private

  def set_order
    @order = current_restaurant.orders.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:discount_id, :notes, order_items_attributes: [ :id, :menu_item_id, :quantity, :notes, :_destroy ])
  end
end
