class CashSession < ApplicationRecord
  belongs_to :restaurant
  belongs_to :opened_by, class_name: "User"
  belongs_to :closed_by, class_name: "User", optional: true
  has_many :cash_movements, dependent: :destroy
  has_many :orders, dependent: :nullify
  has_many :payments, dependent: :nullify

  acts_as_tenant :restaurant

  enum :status, { open: 0, closed: 1 }, default: :open

  validates :opening_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :opened_at, presence: true

  scope :recent, -> { order(opened_at: :desc) }

  def sales_total
    payments.sum(:amount)
  end

  def movements_total
    cash_movements.sum("CASE WHEN kind = 0 THEN amount ELSE -amount END")
  end

  def cash_payments_total
    payments.where(method: :cash).sum(:amount)
  end

  def calculated_expected_amount
    opening_amount + cash_payments_total + movements_total
  end

  def close!(counted_amount:, closed_by:, notes: nil)
    expected = calculated_expected_amount
    update!(
      status: :closed,
      closed_at: Time.current,
      closed_by: closed_by,
      counted_amount: counted_amount,
      expected_amount: expected,
      difference_amount: counted_amount - expected,
      notes: notes
    )
  end
end
