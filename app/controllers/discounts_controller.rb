class DiscountsController < AuthenticatedController
  before_action :set_discount, only: [ :edit, :update, :destroy ]

  def index
    @discounts = current_restaurant.discounts.ordered
  end

  def new
    @discount = current_restaurant.discounts.build(kind: :percentage, active: true)
  end

  def create
    @discount = current_restaurant.discounts.build(discount_params)
    if @discount.save
      redirect_to discounts_path, notice: "Descuento creado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @discount.update(discount_params)
      redirect_to discounts_path, notice: "Descuento actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @discount.destroy
    redirect_to discounts_path, notice: "Descuento eliminado."
  end

  private

  def set_discount
    @discount = current_restaurant.discounts.find(params[:id])
  end

  def discount_params
    params.require(:discount).permit(:name, :kind, :value, :active, :requires_authorization, :starts_at, :ends_at)
  end
end
