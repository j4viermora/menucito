class MenuCategoriesController < AuthenticatedController
  before_action :set_menu_category, only: [ :edit, :update, :destroy ]

  def index
    @menu_categories = current_restaurant.menu_categories.ordered.includes(:menu_items)
  end

  def new
    @menu_category = current_restaurant.menu_categories.build
  end

  def create
    @menu_category = current_restaurant.menu_categories.build(menu_category_params)
    if @menu_category.save
      redirect_to menu_categories_path, notice: "Categoría creada."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @menu_category.update(menu_category_params)
      redirect_to menu_categories_path, notice: "Categoría actualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @menu_category.destroy
    redirect_to menu_categories_path, notice: "Categoría eliminada."
  end

  private

  def set_menu_category
    @menu_category = current_restaurant.menu_categories.find(params[:id])
  end

  def menu_category_params
    params.require(:menu_category).permit(:name, :position, :active)
  end
end
