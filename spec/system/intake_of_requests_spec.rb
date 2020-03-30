require 'rails_helper'

RSpec.feature "Intake of aid request", type: :system, headless: false do
  it "handles the happy path" do
    # caller calls

    visit root_path
    click_on "New"

    # volunteer A enters information
    fill_in "Volunteer name", with: "GOB"
    fill_in "Caller first name", with: "Steve"
    fill_in "Caller last name", with: "Holt"
    fill_in "Caller phone number", with: "1-555-555-5555"
    fill_in "Caller address", with: "517 W 20th St\nRichmond VA 23225"
    fill_in "Supplies needed", with: "bread, soup, bleach, paper towels"
    fill_in "Persons", with: "2 adults, 1 child"
    fill_in "Notes", with: "1 adult is diabetic"
    click_on "Submit"

    # aid request is saved
    expect(current_path).to eql(aid_request_path(AidRequest.last))
    expect(find(".ShowAidRequest-indicationsArea")).to have_content("DIABETIC")
    expect(find(".ShowAidRequest-callerName")).to have_content("Holt, Steve")
    expect(find(".ShowAidRequest-callerPhone")).to have_content("(555) 555-5555")
    expect(find(".ShowAidRequest-callerAddress")).to have_content("517 W 20th St\nRichmond VA 23225")
    expect(find(".ShowAidRequest-persons")).to have_content("2 adults, 1 child")
    expect(find(".ShowAidRequest-notes")).to have_content("1 adult is diabetic")

    # volunteer B picks request
    click_on "Fulfill request"
    # expect(current_path).to eq(new_aid_request_distribution_path(@aid_request))


    # volunteer C checks off items
    # volunteer C creates delivery
    # volunteer D ships and marks complete
  end
end
