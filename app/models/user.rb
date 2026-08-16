class User < ApplicationRecord
  belongs_to :restaurant

  acts_as_tenant :restaurant

  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  enum :role, { waiter: 0, cashier: 1, kitchen: 2, admin: 3, owner: 4 }, default: :waiter

  validates :name, presence: true

  scope :active, -> { where(active: true) }

  # Serves tables: everyone except kitchen staff.
  def front_of_house?
    waiter? || cashier? || can_manage_restaurant?
  end

  # Sells over the counter (POS). Waiters manage tables, not counter sales.
  def can_sell_at_counter?
    cashier? || can_manage_restaurant?
  end

  # Opens/closes the register and records cash movements.
  def can_manage_cash?
    cashier? || can_manage_restaurant?
  end

  # Sees the kitchen display (pending/sent dishes).
  def kitchen_access?
    kitchen? || can_manage_restaurant?
  end

  # Menu, discounts, tables setup, and staff management.
  def can_manage_restaurant?
    admin? || owner?
  end

  # Where to land this user right after sign-in, or when they hit a page
  # their role can't access.
  def home_path
    if can_sell_at_counter?
      Rails.application.routes.url_helpers.pos_path
    elsif front_of_house?
      Rails.application.routes.url_helpers.dining_tables_path
    else
      Rails.application.routes.url_helpers.kitchen_path
    end
  end
end
