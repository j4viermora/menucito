class CashMovement < ApplicationRecord
  belongs_to :restaurant
  belongs_to :cash_session
  belongs_to :created_by, class_name: "User"

  acts_as_tenant :restaurant

  enum :kind, { income: 0, expense: 1 }, default: :expense

  validates :description, presence: true
  validates :amount, numericality: { greater_than: 0 }
  validate :cash_session_must_be_open

  scope :recent, -> { order(created_at: :desc) }

  private

  def cash_session_must_be_open
    errors.add(:cash_session, "debe estar abierta") if cash_session && cash_session.closed?
  end
end
