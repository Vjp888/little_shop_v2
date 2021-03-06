require 'rails_helper'

RSpec.describe 'Merchant Item Update', type: :feature do
  before :each do
    @merchant = create(:merchant)
    @items = create_list(:item,2,  user: @merchant)
    @inactive_item = create(:inactive_item, user: @merchant)

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
  end

  it 'can disable an item' do
    visit dashboard_items_path
    within "#merchant-item-#{@items[0].id}" do
      click_button "Disable"
    end

    expect(current_path).to eq(dashboard_items_path)
    expect(page).to have_content("#{@items[0].name} Disabled")
    within "#merchant-item-#{@items[0].id}" do
      expect(page).to have_button("Enable")
    end

    expect(Item.find(@items[0].id).enabled).to eq(false)
  end

  it 'can enable an item' do
    visit dashboard_items_path

    within "#merchant-item-#{@inactive_item.id}" do
      click_button "Enable"
    end

    expect(current_path).to eq(dashboard_items_path)

    expect(page).to have_content("#{@inactive_item.name} Enabled")
    within "#merchant-item-#{@inactive_item.id}" do
      expect(page).to have_button("Disable")
    end

    expect(Item.find(@inactive_item.id).enabled).to eq(true)
  end

  describe 'Editing item attributes via form' do
    it 'pre-populated with old info' do
      visit dashboard_items_path
      within "#merchant-item-#{@inactive_item.id}" do
        click_link "Edit"
      end

      expect(current_path).to eq(edit_dashboard_item_path(@inactive_item))

      expect(page).to have_field("Name", with:@inactive_item.name)
      expect(page).to have_field("Description", with:@inactive_item.description)
      expect(page).to have_field("Price", with:@inactive_item.current_price)
      expect(page).to have_field("Image URL", with:@inactive_item.image_url)
      expect(page).to have_field("Inventory", with:@inactive_item.quantity)
    end

    it 'accepts valid info, messaging that item was edited' do
      new_info = attributes_for(:item)
      visit edit_dashboard_item_path(@inactive_item)

      fill_in "Name", with:new_info[:name]
      fill_in "Description", with:new_info[:description]
      fill_in "Price", with:new_info[:current_price]
      fill_in "Image URL", with:new_info[:image_url]
      fill_in "Inventory", with:new_info[:quantity]

      click_button "Edit Item"

      expect(current_path).to eq(dashboard_items_path)
      expect(page).to have_content("#{@inactive_item.name} Edited")

      within "#merchant-item-#{@inactive_item.id}" do
        expect(page).to have_content(new_info[:name])
        expect(page).to have_content(new_info[:current_price])
        expect(page).to have_xpath("//img[@src='#{new_info[:image_url]}']")
        expect(page).to have_content(new_info[:quantity])

        expect(page).not_to have_content(@inactive_item.name)
        expect(page).not_to have_content(@inactive_item.current_price)
        expect(page).not_to have_content(@inactive_item.description)
        expect(page).not_to have_content(@inactive_item.quantity)
      end
    end

    describe 'validates information for edited items' do

      it 'defaults to defalut image if field made blank' do
        visit edit_dashboard_item_path(@inactive_item)
        fill_in "Image URL", with:""
        click_button "Edit Item"
        expect(page).to have_xpath("//img[@src='http://www.spore.com/static/image/500/404/515/500404515704_lrg.png']")

      end
      it 'cannot have a quantity of less than 0' do
        visit edit_dashboard_item_path(@inactive_item)
        fill_in "Inventory", with:""
        click_button "Edit Item"
        expect(page).to have_content("Quantity can't be blank")

        fill_in "Inventory", with:-10
        click_button "Edit Item"
        expect(page).to have_content("Quantity must be greater than or equal to 0")

        # Below, this is a kludge-y test, form does not allow input of floats
        # So this is very sad-path of a forced input
        fill_in "Inventory", with:1.5
        expect(page).to have_content("Quantity must be greater than or equal to 0")

        fill_in "Inventory", with: 5
        click_button "Edit Item"
        expect(current_path).to eq(dashboard_items_path)

      end

      it 'must have a price greater than 0.00' do
        visit edit_dashboard_item_path(@inactive_item)

        fill_in "Price", with:""
        click_button "Edit Item"
        expect(page).to have_content("Price can't be blank")

        fill_in "Price", with:0.00
        click_button "Edit Item"
        expect(page).to have_content("Price must be greater than 0")

        fill_in "Price", with: -1.00
        expect(page).to have_content("Price must be greater than 0")
        click_button "Edit Item"

        fill_in "Price", with: 1.00
        click_button "Edit Item"
        expect(current_path).to eq(dashboard_items_path)
      end
    end

  end
end
