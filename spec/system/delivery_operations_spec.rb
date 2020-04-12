require 'rails_helper'

RSpec.feature "Delivery operations", type: :system, headless: false do
  it "allows a fulfillment in a delivery to be returned" do
    delivery = FactoryBot.create :delivery, fulfillment_ct: 3
    sign_in! delivery.driver
    click_on "My deliveries"
    click_on "3 fulfillments started less than a minute ago"
    within(all(".ViewDelivery-reportStatusArea").first) do
      fill_in "Message", with: "Nobody home"
      click_on "Mark returned"
    end
  end
end
