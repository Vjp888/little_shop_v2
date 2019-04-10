class MerchantsController < ApplicationController
  def index
    @merchants = User.active_merchants
    # @top_three_sellers = @merchants.top_three_sellers
    @fastest_three = @merchants.sort_by_fulfillment(:asc)
    @slowest_three = @merchants.sort_by_fulfillment(:desc)
    @three_largest_orders = Order.largest_orders
    @top_three_cities = User.top_three_cities
    @top_three_states = User.top_three_states
  end
end
