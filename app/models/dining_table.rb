class DiningTable < ApplicationRecord
  belongs_to :restaurant
  has_many :orders, dependent: :nullify

  acts_as_tenant :restaurant

  enum :status, { free: 0, occupied: 1, reserved: 2, closing: 3 }, default: :free

  validates :code, presence: true, uniqueness: { scope: :restaurant_id }
  validates :capacity, numericality: { greater_than: 0 }

  scope :ordered, -> { order(:position, :code) }

  def open_order
    orders.where.not(status: [ :paid, :cancelled ]).order(created_at: :desc).first
  end

end
