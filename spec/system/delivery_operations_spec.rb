require 'rails_helper'

RSpec.feature "Delivery operations", type: :system, headless: false do
  it "allows a fulfillment in a delivery to be returned" do
    delivery = FactoryBot.create :delivery, fulfillment_ct: 3
    sign_in! delivery.driver
    click_on "My deliveries"
    click_on "3 fulfillments started less than a minute ago"
    within(".ViewDelivery-markReturnedArea button") do
      click_on "Return"
    end
    within(".ViewDelivery-returnNotes") do
      fill_in "Notes", with: "Nobody home"
      click_on "Submit"
    end

  end
end
