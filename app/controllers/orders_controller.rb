class OrdersController < AuthenticatedController
  before_action { require_permission!(:front_of_house?) }
  before_action(only: :bill) { require_permission!(:can_sell_at_counter?) }
  before_action(only: :pay) { require_permission!(:can_collect_payment?) }
  before_action :set_order

  layout(-> { false if action_name.in?(%w[comanda bill]) })

  def show
  end

  def update
    if @order.update(order_params)
      @order.recalculate_totals!
      KitchenBroadcast.sync(current_restaurant)
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

  def bill
  end

  def send_to_kitchen
    pending_ids = @order.order_items.pending.pluck(:id)

    if pending_ids.empty?
      redirect_to (@order.dining_table ? dining_table_path(@order.dining_table) : @order), alert: "No hay platos nuevos para enviar a cocina."
      return
    end

    @order.order_items.where(id: pending_ids).update_all(status: :printed)
    @order.update!(status: :sent_to_kitchen) if @order.open?
    KitchenBroadcast.sync(current_restaurant)
    KitchenBroadcast.chime(current_restaurant)
    redirect_to (@order.dining_table ? dining_table_path(@order.dining_table) : @order), notice: "Pedido enviado a cocina."
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
    KitchenBroadcast.sync(current_restaurant)
    redirect_to order_path(@order, prompt_print: true), notice: "Pedido pagado."
  end

  def cancel
    @order.update!(status: :cancelled)
    @order.dining_table&.update(status: :free)
    KitchenBroadcast.sync(current_restaurant)
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
