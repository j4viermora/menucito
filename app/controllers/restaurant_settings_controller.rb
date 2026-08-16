class RestaurantSettingsController < AuthenticatedController
  before_action { require_permission!(:can_manage_restaurant?) }

  def edit
    @restaurant = current_restaurant
  end

  def update
    @restaurant = current_restaurant
    if @restaurant.update(restaurant_params)
      redirect_to edit_restaurant_settings_path, notice: "Configuración actualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def restaurant_params
    params.require(:restaurant).permit(:waiters_can_collect_payment)
  end
end
