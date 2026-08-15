class DiningTablesController < AuthenticatedController
  before_action :set_dining_table, only: [ :show, :edit, :update, :destroy, :qr ]

  def index
    @dining_tables = current_restaurant.dining_tables.ordered
  end

  def show
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
