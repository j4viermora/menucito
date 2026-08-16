class Payment < ApplicationRecord
  belongs_to :restaurant
  belongs_to :order
  belongs_to :cash_session, optional: true

  acts_as_tenant :restaurant

  delegate :currency, to: :restaurant, allow_nil: true
  monetize :amount_cents, with_model_currency: :currency

  enum :method, { cash: 0, card: 1, transfer: 2 }, default: :cash

  validates :amount, numericality: { greater_than: 0 }
end
