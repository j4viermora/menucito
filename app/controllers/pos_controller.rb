class PosController < AuthenticatedController
  before_action { require_permission!(:can_sell_at_counter?) }

  def index
    @cash_session = current_restaurant.current_cash_session
    @categories = current_restaurant.menu_categories.active.ordered.includes(menu_items: :menu_category)
    @menu_items = current_restaurant.menu_items.available.ordered
    @discounts = current_restaurant.discounts.active.ordered
    @order = current_restaurant.orders.build(order_type: :counter)
  end

  def create
    unless current_restaurant.current_cash_session
      redirect_to pos_path, alert: "Debes abrir la caja antes de registrar ventas."
      return
    end

    @order = current_restaurant.orders.build(
      order_type: :counter,
      status: :open,
      created_by: current_user,
      cash_session: current_restaurant.current_cash_session,
      discount_id: order_params[:discount_id].presence
    )

    items = JSON.parse(params[:cart_items].presence || "[]")
    items.each do |item|
      menu_item = current_restaurant.menu_items.find(item["menu_item_id"])
      @order.order_items.build(menu_item: menu_item, quantity: item["quantity"].to_i)
    end

    if @order.order_items.empty?
      redirect_to pos_path, alert: "Agrega al menos un producto a la venta."
      return
    end

    ActiveRecord::Base.transaction do
      @order.save!
      @order.recalculate_totals!
      @order.payments.create!(
        restaurant: current_restaurant,
        cash_session: current_restaurant.current_cash_session,
        method: order_params[:payment_method].presence || :cash,
        amount: @order.total
      )
      @order.update!(status: :paid)
    end

    redirect_to comanda_order_path(@order), notice: "Venta ##{@order.order_number} registrada."
  rescue ActiveRecord::RecordInvalid, JSON::ParserError => e
    redirect_to pos_path, alert: "No se pudo registrar la venta: #{e.message}"
  end

  private

  def order_params
    params.permit(:discount_id, :payment_method)
  end
end
