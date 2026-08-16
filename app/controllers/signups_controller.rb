class SignupsController < ApplicationController
  skip_before_action :set_current_tenant_from_subdomain

  layout "marketing"

  def new
    @restaurant = Restaurant.new
    ActsAsTenant.without_tenant { @user = User.new }
  end

  def create
    @restaurant = Restaurant.new(restaurant_params)

    ActiveRecord::Base.transaction do
      @restaurant.save!
      ActsAsTenant.with_tenant(@restaurant) do
        @user = @restaurant.users.build(user_params.merge(role: :owner))
        @user.save!
      end
    end

    redirect_to root_url(subdomain: @restaurant.subdomain, host: request.domain, port: request.port),
      allow_other_host: true, notice: "¡Restaurante creado! Inicia sesión con tu correo y contraseña."
  rescue ActiveRecord::RecordInvalid
    ActsAsTenant.without_tenant { @user ||= User.new(user_params) }
    render :new, status: :unprocessable_entity
  end

  private

  def restaurant_params
    params.require(:restaurant).permit(:name, :subdomain, :timezone, :currency)
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
