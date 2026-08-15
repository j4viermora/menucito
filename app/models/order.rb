class Order < ApplicationRecord
  belongs_to :restaurant
  belongs_to :dining_table, optional: true
  belongs_to :cash_session, optional: true
  belongs_to :created_by, class_name: "User"
  belongs_to :discount, optional: true
  has_many :order_items, dependent: :destroy
  has_many :payments, dependent: :destroy

  acts_as_tenant :restaurant

  enum :order_type, { counter: 0, table_service: 1, qr_order: 2 }, default: :counter
  enum :status, { open: 0, sent_to_kitchen: 1, served: 2, paid: 3, cancelled: 4 }, default: :open

  validates :order_number, presence: true, uniqueness: { scope: :restaurant_id }

  before_validation :assign_order_number, on: :create

  accepts_nested_attributes_for :order_items, allow_destroy: true

  scope :recent, -> { order(created_at: :desc) }
  scope :active, -> { where.not(status: [ :paid, :cancelled ]) }

  def recalculate_totals!
    sub = order_items.sum { |i| i.quantity * i.unit_price }
    disc = discount ? discount.amount_for(sub) : 0
    update!(subtotal: sub, discount_amount: disc, total: sub - disc)
  end

  def amount_paid
    payments.sum(:amount)
  end

  def balance_due
    total - amount_paid
  end

  private

  def assign_order_number
    return if order_number.present?
    seq = restaurant.orders.maximum(:id).to_i + 1
    self.order_number = "#{Date.current.strftime('%y%m%d')}-#{seq.to_s.rjust(4, '0')}"
  end
end
