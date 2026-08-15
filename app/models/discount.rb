class Discount < ApplicationRecord
  belongs_to :restaurant
  has_many :orders, dependent: :nullify

  acts_as_tenant :restaurant

  enum :kind, { percentage: 0, fixed_amount: 1 }, default: :percentage

  validates :name, presence: true, uniqueness: { scope: :restaurant_id }
  validates :value, numericality: { greater_than: 0 }
  validate :percentage_within_range

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:name) }

  def available_now?
    return false unless active?
    return false if starts_at.present? && starts_at > Time.current
    return false if ends_at.present? && ends_at < Time.current
    true
  end

  def amount_for(subtotal)
    return 0 if subtotal.blank? || subtotal <= 0
    raw = percentage? ? subtotal * (value / 100.0) : value
    [ raw, subtotal ].min.round(2)
  end

  private

  def percentage_within_range
    return unless percentage? && value.present?
    errors.add(:value, "debe estar entre 0 y 100") if value > 100
  end
end
