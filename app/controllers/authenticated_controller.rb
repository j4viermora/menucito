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
end
