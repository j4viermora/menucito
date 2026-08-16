class DiningTablesController < AuthenticatedController
  before_action :set_dining_table, only: [ :show, :edit, :update, :destroy, :qr, :open ]

  def index
    @dining_tables = current_restaurant.dining_tables.ordered
  end

  def show
    @order = @dining_table.open_order
    @menu_items = current_restaurant.menu_items.available.ordered
    @discounts = current_restaurant.discounts.active.ordered
  end

  def open
    unless current_restaurant.current_cash_session
      redirect_to dining_tables_path, alert: "Debes abrir la caja antes de atender mesas."
      return
    end

    if @dining_table.open_order.nil?
      order = current_restaurant.orders.create!(
        dining_table: @dining_table,
        order_type: :table_service,
        status: :open,
        created_by: current_user,
        cash_session: current_restaurant.current_cash_session
      )
      @dining_table.update!(status: :occupied)
    end

    redirect_to dining_table_path(@dining_table)
  end

  def new
    @dining_table = current_restaurant.dining_tables.build(position: next_position)
  end

  def create
    @dining_table = current_restaurant.dining_tables.build(dining_table_params)
    if @dining_table.save
      redirect_to dining_tables_path, notice: "Mesa #{@dining_table.code} creada."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @dining_table.update(dining_table_params)
      redirect_to dining_tables_path, notice: "Mesa #{@dining_table.code} actualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @dining_table.destroy
    redirect_to dining_tables_path, notice: "Mesa #{@dining_table.code} eliminada."
  end

  def qr
    @menu_url = public_menu_url(table: @dining_table.code, subdomain: current_restaurant.subdomain, host: request.domain, port: request.port)
  end

  private

  def next_position
    (current_restaurant.dining_tables.maximum(:position) || 0) + 1
  end

  def set_dining_table
    @dining_table = current_restaurant.dining_tables.find(params[:id])
  end

  def dining_table_params
    params.require(:dining_table).permit(:code, :capacity, :status, :position)
  end
end
