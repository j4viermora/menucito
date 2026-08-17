class Users::SessionsController < Devise::SessionsController
  # Devise prepends `verify_signed_out_user` for :destroy, which touches
  # `warden.user` (and thus User.find, a tenant-scoped model) before
  # ApplicationController's tenant-setting before_action runs. Prepending
  # here puts tenant resolution ahead of that, since a subclass's own
  # prepend_before_action always lands in front of an inherited one.
  prepend_before_action :set_current_tenant_from_subdomain
end
