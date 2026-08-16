class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_current_tenant_from_subdomain

  rescue_from ActsAsTenant::Errors::NoTenantSet, with: :render_tenant_not_found

  private

  def set_current_tenant_from_subdomain
    subdomain = request.subdomain.presence
    @current_restaurant = subdomain && Restaurant.find_by(subdomain: subdomain, active: true)

    if @current_restaurant.nil?
      render_tenant_not_found
      return false
    end

    ActsAsTenant.current_tenant = @current_restaurant
  end

  def render_tenant_not_found
    render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
  end

  def current_restaurant
    @current_restaurant
  end
  helper_method :current_restaurant

  def after_sign_in_path_for(resource)
    resource.home_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
end
