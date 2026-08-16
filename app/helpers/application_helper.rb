module ApplicationHelper
  ROLE_LABELS = {
    "waiter" => "Mesero", "cashier" => "Cajero", "kitchen" => "Cocina",
    "admin" => "Administrador", "owner" => "Dueño",
  }.freeze

  def role_label(role)
    ROLE_LABELS.fetch(role.to_s, role.to_s.humanize)
  end
end
