# Pushes the kitchen display up to date over Action Cable (via Turbo
# Streams) so a screen left open in the kitchen updates itself without a
# manual refresh. Scoped per restaurant since the display is tenant-specific.
class KitchenBroadcast
  def self.sync(restaurant)
    order_items = OrderItem.kitchen_visible
      .where(restaurant: restaurant)
      .includes(:menu_item, order: :dining_table)
      .order(:created_at)
      .group_by(&:order)

    Turbo::StreamsChannel.broadcast_replace_to(
      restaurant, :kitchen,
      target: "kitchen-board",
      partial: "kitchen/board",
      locals: { order_items: order_items }
    )
  end

  # A separate, content-less ping so the browser can tell "a new order just
  # arrived" (play a sound) apart from routine board updates (no sound).
  def self.chime(restaurant)
    Turbo::StreamsChannel.broadcast_replace_to(
      restaurant, :kitchen,
      target: "kitchen-chime",
      partial: "kitchen/chime"
    )
  end
end
