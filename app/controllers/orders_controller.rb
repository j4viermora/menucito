class OrdersController < AuthenticatedController
  before_action :set_order

  layout false, only: [ :comanda ]

  def show
  end

  def update
    if @order.update(order_params)
      @order.recalculate_totals!
      redirect_to @order, notice: "Pedido actualizado."
    else
      render :show, status: :unprocessable_entity
    end
  end

  def comanda
    @order_items = @order.order_items.includes(:menu_item)
  end

  def send_to_kitchen
    @order.update!(status: :sent_to_kitchen)
    @order.order_items.update_all(status: :printed)
    redirect_to comanda_order_path(@order)
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
