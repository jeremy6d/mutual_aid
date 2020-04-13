require 'rails_helper'

RSpec.feature "Packer operations", type: :system, js: true do
  it "allows a fulfillment to be cancelled" do
    fulfillment = FactoryBot.create :fulfillment
    volunteer = FactoryBot.create(:volunteer)
    sign_in! volunteer
    click_on fulfillment.aid_request.caller_name
    click_on "Packed fulfillment (less than a minute old)"
    accept_confirm { click_on "Cancel" }

    expect(page).to have_content("cancelled")
  end
end
