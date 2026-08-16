class CashSession < ApplicationRecord
  belongs_to :restaurant
  belongs_to :opened_by, class_name: "User"
  belongs_to :closed_by, class_name: "User", optional: true
  has_many :cash_movements, dependent: :destroy
  has_many :orders, dependent: :nullify
  has_many :payments, dependent: :nullify

  acts_as_tenant :restaurant

  delegate :currency, to: :restaurant, allow_nil: true
  monetize :opening_amount_cents, with_model_currency: :currency
  monetize :counted_amount_cents, with_model_currency: :currency, allow_nil: true
  monetize :expected_amount_cents, with_model_currency: :currency, allow_nil: true
  monetize :difference_amount_cents, with_model_currency: :currency, allow_nil: true

  enum :status, { open: 0, closed: 1 }, default: :open

  validates :opening_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :opened_at, presence: true

  scope :recent, -> { order(opened_at: :desc) }

  def sales_total
    Money.new(payments.sum(:amount_cents), currency)
  end

  def movements_total
    cents = cash_movements.sum("CASE WHEN kind = 0 THEN amount_cents ELSE -amount_cents END")
    Money.new(cents, currency)
  end

  def cash_payments_total
    Money.new(payments.where(method: :cash).sum(:amount_cents), currency)
  end

  def sold_orders
    Order.where(id: payments.select(:order_id)).includes(order_items: :menu_item).order(:order_number)
  end

  # Aggregated "what did I sell" breakdown by dish, for the closing report.
  def sales_summary
    items = sold_orders.flat_map(&:order_items)
    items.group_by { |item| item.menu_item.name }.map do |name, group|
      { name: name, quantity: group.sum(&:quantity), total: group.sum(&:line_total) }
    end.sort_by { |row| -row[:total] }
  end

  def calculated_expected_amount
    opening_amount + cash_payments_total + movements_total
  end

  def close!(counted_amount:, closed_by:, notes: nil)
    counted = Money.from_amount(counted_amount, currency)
    expected = calculated_expected_amount
    update!(
      status: :closed,
      closed_at: Time.current,
      closed_by: closed_by,
      counted_amount: counted,
      expected_amount: expected,
      difference_amount: counted - expected,
      notes: notes
    )
  end
end
