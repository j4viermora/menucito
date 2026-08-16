class HomeController < ApplicationController
  skip_before_action :set_current_tenant_from_subdomain

  def index
    subdomain = request.subdomain.presence
    restaurant = subdomain && Restaurant.find_by(subdomain: subdomain, active: true)

    if restaurant
      ActsAsTenant.current_tenant = restaurant
      redirect_to(user_signed_in? ? current_user.home_path : new_user_session_path)
    else
      render :marketing, layout: "marketing"
    end
  end
end
