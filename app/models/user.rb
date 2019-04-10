class User < ApplicationRecord
  validates_presence_of :name,
                        :street_address,
                        :city,
                        :state,
                        :zip_code,
                        :email,
                        :role
  validates :password, presence: true, length: {minimum: 5}, on: :create
  validates :password, length: {minimum: 5}, on: :update, allow_blank: true
  validates_uniqueness_of :email

  has_many :orders
  has_many :items, foreign_key: "merchant_id"

  enum role: ['user', 'merchant', 'admin']

  has_secure_password

  def self.active_merchants
    User.where(role: 1)
        .where(enabled: true)
  end

  def self.all_merchants
    User.where(role: 1)
  end

  def merchant_orders
    items
    .joins(:orders)
    .select("orders.*")
    .distinct
  end

  def top_items
    items
    .select("items.*, sum(order_items.quantity) AS number")
    .joins(:orders)
    .where("orders.status = 2")
    .group(:id)
    .order("number DESC")
    .limit(5)
  end

  def top_states
    items
    .select("customers.state, count(customers.state) as order_count")
    .joins(:orders)
    .joins('INNER JOIN "users" as "customers" ON "customers"."id" = "orders"."user_id"')
    .where("orders.status = 2")
    .group("customers.state")
    .order("order_count DESC")
    .limit(3)
  end

  def items_sold
    items
    .joins(:orders)
    .where("orders.status = 2")
    .sum("order_items.quantity")
  end

  def top_cities
    items
    .select("customers.state, customers.city, count(distinct orders.id) as order_count")
    .joins(:orders)
    .joins('INNER JOIN "users" as "customers" ON "customers"."id" = "orders"."user_id"')
    .where("orders.status = 2")
    .group("customers.state")
    .group("customers.city")
    .order("order_count DESC")
    .limit(3)
  end

  def top_user_orders
    items
    .select("customers.name, count(distinct orders.id) as order_count")
    .joins(:orders)
    .joins('INNER JOIN "users" as "customers" ON "customers"."id" = "orders"."user_id"')
    .where("orders.status = 2")
    .group("customers.name")
    .order("order_count DESC")
    .first
  end

  def top_user_items
    items
    .select("customers.name, sum(order_items.quantity) as item_count")
    .joins(:orders)
    .joins('INNER JOIN "users" as "customers" ON "customers"."id" = "orders"."user_id"')
    .where("orders.status = 2")
    .group("customers.name")
    .order("item_count DESC")
    .first
  end

  def top_users_money
    items
    .select("customers.name, sum(order_items.quantity * order_items.ordered_price) as revenue")
    .joins(:orders)
    .joins('INNER JOIN "users" as "customers" ON "customers"."id" = "orders"."user_id"')
    .where("orders.status = 2")
    .group("customers.name")
    .order("revenue DESC")
    .limit(3)
  end

  def pending_orders
    items.select("orders.id")
         .joins(:orders)
         .where(orders: {status: 0})
         .distinct
         .pluck("orders.id")
  end
end
