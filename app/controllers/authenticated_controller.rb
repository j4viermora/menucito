class AuthenticatedController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_user_belongs_to_tenant

  layout "app"

  private

  def verify_user_belongs_to_tenant
    return unless user_signed_in?
    return if current_user.restaurant_id == current_restaurant&.id

    sign_out(current_user)
    redirect_to new_user_session_path, alert: "Tu usuario no pertenece a este restaurante."
  end

  # Call as a before_action with the permission method to check, e.g.
  # `before_action { require_permission!(:front_of_house?) }`.
  def require_permission!(predicate)
    return if current_user.public_send(predicate)
    redirect_to current_user.home_path, alert: "No tienes permiso para acceder a esta sección."
  end
end
