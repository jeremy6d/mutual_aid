require 'rails_helper'

RSpec.feature "Delivery operations", type: :system, js: true, headless: false do
  let(:aid_request) do 
    FactoryBot.create :aid_request, caller_first_name: "Tobias",
                                    caller_last_name: "Fuenke",
                                    neighborhood: "Sudden Valley",
                                    created_at: 1.hour.ago
  end

  let(:another_request) do
    FactoryBot.create :aid_request, caller_first_name: "George-Michael",
                                    caller_last_name: "Bluth",
                                    neighborhood: "Sudden Valley",
                                    caller_address: "10 Lancelot Ct",
                                    created_at: 1.minute.ago
  end

  let(:one_more_request) do
    FactoryBot.create :aid_request, caller_first_name: "Carl",
                                    caller_last_name: "Weathers",
                                    neighborhood: "Balboa Towers",
                                    caller_address: "1 Balboa Ln"

  end

  let(:driver) { FactoryBot.create :volunteer }
  let(:fulfillments) do
    [ another_request.fulfillments.first,
      one_more_request.fulfillments.last ] +
    aid_request.fulfillments 
  end

  before do 
    PackingSlip.create fulfillments: fulfillments, 
                       creator: FactoryBot.create(:volunteer)
    sign_in! driver
    click_on "Make a delivery"
    all(".delivery_fulfillments input").each { |c| c.check }
    all(".delivery_fulfillments input").at(2).uncheck
    click_on "Start delivery now"
  end

  it "allows a fulfillment in a delivery to be returned with a note" do
    click_on "Sudden Valley / 1203 Main St, Richmond, VA"
    
      expect(all(".ViewDelivery-fulfillmentItem").first.text).to have_content("milk")
      expect(all(".ViewDelivery-fulfillmentItem").last.text).to have_content("oven")
      expect(all(".ViewDelivery-fulfillmentItem").size).to eq(2)
      find(".ViewDelivery-deliveryNote").set "Nobody home"
      click_on "Mark returned"
      expect(find(".ViewDelivery-returnHeader")).to have_content("RETURNED")
      sleep 1
      click_on "Sudden Valley / 1203 Main St, Richmond, VA"
      click_on "Fuenke, Tobias"
    within('.FulfillmentList-listParent') do
      all('.FulfillmentList-fulfillmentItem').map(&:text).all? { |t| t.include? "Packed" }
    end
  end

  it "allows a fulfillment in a delivery to be delivered with a note" do
    click_on "My deliveries"
    click_on "4 fulfillments started less than a minute ago"
    click_on "Balboa Towers / 1 Balboa Ln"
    within(".ViewDelivery-fulfillmentCard:last-child") do
      find(".ViewDelivery-deliveryNote").set "She said thanks!"
      click_on "Mark delivered"
      expect(find(".ViewDelivery-successHeader")).to have_content("Delivered!")
      sleep 1
      click_on "Balboa Towers / 1 Balboa Ln"
      click_on "Weathers, Carl"
    end
    within('.FulfillmentList-listParent') do
      all('.FulfillmentList-fulfillmentItem').map(&:text).all? { |t| t.include? "Delivered" }
    end
    # TODO: the fucking note
  end

  scenario "add fulfillments to an ongoing delivery" do
    click_on "My deliveries"
    click_on "4 fulfillments started less than a minute ago"
    click_on "Add fulfillments"
    find(".ModifyDelivery-newFulfillments input").check
    click_on "Add these fulfillments"
    click_on "Sudden Valley / 1203 Main St, Richmond, VA" 
sleep 1
    expect(all(".ViewDelivery-fulfillmentItem").size).to eq(3)
    click_on "Fuenke, Tobias"
    expect(all(".FulfillmentList-fulfillmentItem").all? { |i| i.text.include? "On The Way" }).to be true
  end

  scenario "disallow editing delivery after complete"
end
