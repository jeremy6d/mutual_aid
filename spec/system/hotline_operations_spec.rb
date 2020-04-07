require 'rails_helper'

RSpec.feature "Hotline operations", type: :system, headless: false do
  let(:attributes) { FactoryBot.attributes_for(:random_aid_request) }
  before do
    sign_in! FactoryBot.create(:volunteer)
    click_on "New"
  end

  it "marks a request as urgent" do
    submit_aid_request_for(attributes.merge(urgent: true))

    expect(find(".ShowAidRequest-urgent")).to be_visible
    click_on "Back"

    expect(all('tbody tr').first.matches_css?(".bg-danger")).to be true
  end

  it "marks a request as requiring a callback" do
    submit_aid_request_for(attributes.merge(call_back: true))

    expect(find(".ShowAidRequest-callBack")).to be_visible
    click_on "Back"

    expect(all('tbody tr').first.matches_css?(".bg-success")).to be true
  end

  it "allows dismissal" do
    submit_aid_request_for(attributes.merge(call_back: true))

    expect(find(".ShowAidRequest-status")).to have_content("Unfulfilled")
    page.accept_confirm { click_on "Dismiss" }

    expect(find(".ShowAidRequest-status")).to have_content("Dismissed")
  end
end
