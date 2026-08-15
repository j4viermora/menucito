class MenuItemsController < AuthenticatedController
  before_action :set_menu_item, only: [ :edit, :update, :destroy ]

  def index
    @menu_items = current_restaurant.menu_items.includes(:menu_category).ordered
    @menu_items = @menu_items.where(menu_category_id: params[:menu_category_id]) if params[:menu_category_id].present?
  end

  def new
    @menu_item = current_restaurant.menu_items.build
  end

  def create
    @menu_item = current_restaurant.menu_items.build(menu_item_params)
    if @menu_item.save
      redirect_to menu_items_path, notice: "Plato creado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @menu_item.update(menu_item_params)
      redirect_to menu_items_path, notice: "Plato actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @menu_item.destroy
    redirect_to menu_items_path, notice: "Plato eliminado."
  rescue ActiveRecord::InvalidForeignKey, ActiveRecord::RecordNotDestroyed
    redirect_to menu_items_path, alert: "No se puede eliminar: tiene pedidos asociados."
  end

  private

  def set_menu_item
    @menu_item = current_restaurant.menu_items.find(params[:id])
  end

  def menu_item_params
    params.require(:menu_item).permit(:name, :description, :price, :available, :position, :menu_category_id, :image)
  end
end
