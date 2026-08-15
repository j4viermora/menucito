class User < ApplicationRecord
  belongs_to :restaurant

  acts_as_tenant :restaurant

  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  enum :role, { waiter: 0, cashier: 1, kitchen: 2, admin: 3, owner: 4 }, default: :waiter

  validates :name, presence: true

  scope :active, -> { where(active: true) }

  def can_manage_restaurant?
    admin? || owner?
  end
end
