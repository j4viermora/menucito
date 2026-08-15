class PublicMenuController < ApplicationController
  layout "public_menu"

  def show
    @restaurant = current_restaurant
    @table = current_restaurant.dining_tables.find_by(code: params[:table])
    @categories = current_restaurant.menu_categories.active.ordered
      .includes(menu_items: { image_attachment: :blob })
  end
end
