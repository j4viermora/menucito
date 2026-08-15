class MenuCategory < ApplicationRecord
  belongs_to :restaurant
  has_many :menu_items, dependent: :destroy

  acts_as_tenant :restaurant

  validates :name, presence: true, uniqueness: { scope: :restaurant_id }

  scope :ordered, -> { order(:position, :name) }
  scope :active, -> { where(active: true) }
end
