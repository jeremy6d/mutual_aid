require 'rails_helper'

RSpec.feature "Delivery operations", type: :system, js: true do
  it "allows a fulfillment in a delivery to be returned with a note" do
    delivery = FactoryBot.create :delivery, fulfillment_ct: 3
    sign_in! delivery.driver
    click_on "My deliveries"
    click_on "3 fulfillments started less than a minute ago"
    within(".ViewDelivery-fulfillmentCard:first-child") do
      find("#message").set "Nobody home"
      click_on "Mark returned"
      expect(find(".ViewDelivery-returnHeader")).to have_content("RETURNED")
      sleep 1
      find(".ViewDelivery-collapseToggle").click
      click_on "Loblaw, Robert"
    end
    find(".FulfillmentList-fulfillmentItem a").click
    expect(page).to have_content("packed")
  end

  it "allows a fulfillment in a delivery to be delivered with a note" do
    delivery = FactoryBot.create :delivery, fulfillment_ct: 3
    sign_in! delivery.driver
    click_on "My deliveries"
    click_on "3 fulfillments started less than a minute ago"
    within(".ViewDelivery-fulfillmentCard:first-child") do
      find("#message").set "She said thanks!"
      click_on "Mark delivered"
      expect(find(".ViewDelivery-successHeader")).to have_content("Delivered!")
      sleep 1
      find(".ViewDelivery-collapseToggle").click
      click_on "Loblaw, Robert"
    end
    find(".FulfillmentList-fulfillmentItem a").click
    expect(page).to have_content("delivered")
  end
end
