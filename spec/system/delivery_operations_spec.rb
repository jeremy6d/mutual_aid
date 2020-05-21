require 'rails_helper'

RSpec.feature "Delivery operations", type: :system, js: true, headless: false do
  let(:aid_request) do 
    FactoryBot.create :random_aid_request, caller_first_name: "Tobias",
                                           caller_last_name: "Fuenke"
  end
  let(:fulfillment) do 
    FactoryBot.create :fulfillment, aid_request: aid_request
  end
  let(:delivery) do 
    FactoryBot.create :delivery, fulfillments: [fulfillment]
  end

  it "allows a fulfillment in a delivery to be returned with a note" do
    sign_in! delivery.driver
    click_on "My deliveries"
sleep 1
    click_on "1 fulfillment started less than a minute ago"
sleep 1
    within(".ViewDelivery-fulfillmentCard:first-child") do
      find("#message").set "Nobody home"
      click_on "Mark returned"
      expect(find(".ViewDelivery-returnHeader")).to have_content("RETURNED")
      sleep 1
      find(".ViewDelivery-collapseToggle").click
      click_on "Fuenke, Tobias"
    end
sleep 1    
    find(".FulfillmentList-fulfillmentItem a").click
    expect(page).to have_content("packed")
  end

  it "allows a fulfillment in a delivery to be delivered with a note" do
    sign_in! delivery.driver
    click_on "My deliveries"
    click_on "1 fulfillment started less than a minute ago"
    within(".ViewDelivery-fulfillmentCard:first-child") do
      find("#message").set "She said thanks!"
      click_on "Mark delivered"
      expect(find(".ViewDelivery-successHeader")).to have_content("Delivered!")
      sleep 1
      find(".ViewDelivery-collapseToggle").click
      click_on "Fuenke, Tobias"
    end
sleep 1
    find(".FulfillmentList-fulfillmentItem a").click
    expect(page).to have_content("delivered")
  end

  scenario "add fulfillments to an ongoing delivery" do
    delivery_2 = FactoryBot.create :delivery, fulfillment_ct: 2
    f1, f2 = delivery_2.fulfillments
    f3 = FactoryBot.create :fulfillment
    sign_in! delivery_2.driver
    click_on "My deliveries"
    click_on "2 fulfillments started less than a minute ago"
    click_on "Add fulfillments"
    # within(".ModifyDelivery-currentFulfillments") { uncheck f2.aid_request.id.to_s }
    within(".ModifyDelivery-newFulfillments") { check f3.aid_request.id.to_s }
    click_on "Add these fulfillments"
    expect(page).to have_content(f1.public_id)
    expect(page).to have_content(f3.public_id)
    expect(page).to have_content(f2.public_id)
    click_on "Requests"
    click_on f2.aid_request.caller_name
    expect(find(".FulfillmentList-fulfillmentItem a")).to have_content("On The Way")
  end

  scenario "disallow editing delivery after complete"
end
