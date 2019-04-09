require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'validations' do
    it {should validate_presence_of :name}
    it {should validate_presence_of :description}
    it {should validate_presence_of :image_url}
    it {should validate_presence_of :quantity}
    it {should validate_presence_of :current_price}
    # it {should validate_exclusion_of(:enabled).in_array([nil])}
    # it {should validate_presence_of :merchant_id}

  end

  describe 'relationships' do
    it {should belong_to :user}
    it {should have_many :order_items}
    it {should have_many(:orders).through :order_items}
  end

  describe 'class methods' do
    it ".enabled_items" do
      merchant  = create(:merchant)
      item1 = create(:item, user: merchant)
      item2 = create(:item, user: merchant)
      item3 = create(:inactive_item, user: merchant)

      expect(Item.enabled_items).to eq([item1, item2])
    end

    it ".sort_sold" do
      merchant  = create(:merchant)
      item1 = create(:item, user: merchant)
      item2 = create(:item, user: merchant)
      item3 = create(:item, user: merchant)
      item4 = create(:item, user: merchant)
      item5 = create(:item, user: merchant)

      shopper = create(:user)
      order = create(:shipped_order, user: shopper)

      create(:fulfilled_order_item, order: order, item: item1, quantity: item1.quantity)
      create(:fulfilled_order_item, order: order, item: item2, quantity: item2.quantity)
      create(:fulfilled_order_item, order: order, item: item3, quantity: item3.quantity)
      create(:fulfilled_order_item, order: order, item: item4, quantity: item4.quantity)
      create(:fulfilled_order_item, order: order, item: item5, quantity: item5.quantity)

      expect(Item.sort_sold("ASC")).to eq([item1, item2, item3, item4, item5])
      expect(Item.sort_sold("DESC")).to eq([item5, item4, item3, item2, item1])
    end

    it ".find_by_order" do
      merchant1 = create(:merchant)
      shopper = create(:user)
      merchant2 = create(:merchant)
      item1 = create(:item, user: merchant1)
      item2 = create(:item, user: merchant2)
      item3 = create(:item, user: merchant1)

      order = create(:order, user: shopper)
      oi1 = create(:order_item, order: order, item: item1)
      oi2 = create(:order_item, order: order, item: item2)
      oi3 = create(:order_item, order: order, item: item3)

      expect(Item.find_by_order(order, merchant1)).to eq([item1, item3])
    end
  end

  describe 'instance methods' do
    before :each do
      @merchant  = create(:merchant)
      @item1 = create(:item, user: @merchant, quantity: 100)
      @item2 = create(:item, user: @merchant, quantity: 100)
      @shopper = create(:user)
      @order = create(:fast_shipped_order, user: @shopper)
      @order2 = create(:order, user: @shopper)

      create(:fast_fulfilled_order_item, order: @order, item: @item1, quantity: 10, created_at: "Wed, 03 Apr 2019 14:11:25 UTC +00:00", updated_at: "Thu, 04 Apr 2019 14:11:25 UTC +00:00")
      create(:fast_fulfilled_order_item, order: @order, item: @item1, quantity: 5, created_at: "Wed, 03 Apr 2019 14:11:25 UTC +00:00", updated_at: "Thu, 04 Apr 2019 14:11:25 UTC +00:00")
      create(:order_item, order: @order2, item: @item1, quantity: 5)
      create(:fast_fulfilled_order_item, order: @order2, item: @item2, quantity: 7, created_at: "Mon, 01 Apr 2019 14:11:25 UTC +00:00", updated_at: "Thu, 04 Apr 2019 14:11:25 UTC +00:00")
    end

    it ".total_sold" do
      expect(@item1.total_sold).to eq(15)
    end

    it ".fullfillment_time" do
      expect(@item1.fullfillment_time).to eq(1)
    end

    it '.ordered?' do
      item3 = create(:item)

      expect(item3.ordered?).to eq(false)
      expect(@item2.ordered?).to eq(true)
    end

    it ".amount_ordered" do
      expect(@item2.amount_ordered(@order2)).to eq(7)
    end

    it ".fulfilled?" do
      expect(@item1.fulfilled?(@order)).to eq(true)
      expect(@item1.fulfilled?(@order2)).to eq(false)
    end
  end
end
