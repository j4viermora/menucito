class Restaurant < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :dining_tables, dependent: :destroy
  has_many :menu_categories, dependent: :destroy
  has_many :menu_items, dependent: :destroy
  has_many :discounts, dependent: :destroy
  has_many :cash_sessions, dependent: :destroy
  has_many :orders, dependent: :destroy

  before_validation { self.subdomain = subdomain.to_s.strip.downcase }
  before_validation { self.slug = slug.presence || subdomain }

  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: true,
    format: { with: /\A[a-z0-9][a-z0-9-]*\z/, message: "solo minúsculas, números y guiones" }
  validates :slug, presence: true, uniqueness: true

  def current_cash_session
    cash_sessions.find_by(status: :open)
  end
end
