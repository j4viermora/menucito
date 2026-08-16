class OrderItem < ApplicationRecord
  belongs_to :restaurant
  belongs_to :order
  belongs_to :menu_item

  acts_as_tenant :restaurant

  delegate :currency, to: :restaurant, allow_nil: true
  monetize :unit_price_cents, with_model_currency: :currency

  enum :status, { pending: 0, printed: 1, served: 2 }, default: :pending

  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }

  before_validation :assign_unit_price, on: :create

  def line_total
    unit_price * quantity
  end

  private

  def assign_unit_price
    self.unit_price = menu_item.price if unit_price.blank? && menu_item.present?
  end
end
