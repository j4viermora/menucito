class MenuItem < ApplicationRecord
  belongs_to :restaurant
  belongs_to :menu_category
  has_many :order_items, dependent: :restrict_with_error
  has_one_attached :image

  acts_as_tenant :restaurant

  delegate :currency, to: :restaurant, allow_nil: true
  monetize :price_cents, with_model_currency: :currency

  validates :name, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  scope :ordered, -> { order(:position, :name) }
  scope :available, -> { where(available: true) }

  def formatted_price
    ActiveSupport::NumberHelper.number_to_currency(price.to_f, unit: restaurant.currency + " ", precision: 0)
  end
end
