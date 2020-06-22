require 'rails_helper'

RSpec.feature "Hotline operations", type: :system, js: true, headless: false do
  let(:attributes) { FactoryBot.attributes_for(:random_aid_request) }
  before do
    sign_in! FactoryBot.create(:volunteer)
    click_on "New"
  end

  it "marks a request as urgent but not a call back" do
    submit_aid_request_for(attributes.merge(urgent: true))

    expect(find(".ShowAidRequest-urgent")).to be_visible
    expect(find(".ShowAidRequest-status")).to have_content("In Progress")
    expect(all(".FulfillmentList-fulfillmentItem").first).to have_content("Pending")
    click_on "Back"

    expect(all('tbody tr').first.matches_css?(".bg-danger")).to be true
  end

  it "marks a request as requiring a call back" do
    submit_aid_request_for(attributes.merge(needs_call_back: true))

    expect(find(".ShowAidRequest-status")).to have_content("Call Back")
    expect(page).not_to have_selector(".ShowAidRequest-urgent")
    click_on "Back"

    expect(all('tbody tr').first.matches_css?(".bg-success")).to be true
  end

  it "allows dismissal" do
    submit_aid_request_for(attributes.merge(needs_call_back: true))

    expect(find(".ShowAidRequest-status")).to have_content("Call Back")
    page.accept_confirm { click_on "Dismiss" }

    expect(find(".ShowAidRequest-status")).to have_content("Dismissed")
  end
end
