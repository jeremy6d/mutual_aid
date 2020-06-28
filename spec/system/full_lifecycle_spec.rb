require 'rails_helper'

RSpec.feature "Aid request full lifecycle", type: :system, js: true do
  # Provision users for our script
  { hotline_volunteer: %w(Buster Bluth),
    packer_volunteer: %w(Gene Parmesean),
    driver_volunteer: %w(George Bluth) }.each do |role, names|
    let!(role) do 
      FactoryBot.create :volunteer, first_name: names.first,
                                    last_name: names.last
    end
  end

  # Provision an existing request with a pending fulfillment
  let!(:older_request) do
    FactoryBot.create :aid_request, caller_first_name: "Lindsay",
                                    caller_last_name:  "Bluth",
                                    caller_address: "100 E Main St, Richmond VA"
  end

  before do
    # User HOTLINE enters request 1 information and submits
    # - information is persisted to the database
    # - request is marked "unfulfilled"
    # - redirects to the new request form
    # - shows a flash saying message entered

    signing_in_as(hotline_volunteer) do
      click_on "New"
      submit_aid_request_for caller_first_name: "Steve",
                             caller_last_name: "Holt",
                             caller_phone_number: "1-555-555-5555",
                             caller_address: "517 W 20th St\nRichmond VA 23225", 
                             supplies_needed: "bread, soup, bleach, paper towels",
                             special_requests: "A/C unit, microwave",
                             persons: "2 adults, 1 child",
                             notes: "1 adult is diabetic"
      expect(current_path).to eql(aid_request_path(AidRequest.last))
      expect(find(".ShowAidRequest-indicationsArea")).to have_content("DIABET")
      expect(find(".ShowAidRequest-callerName")).to have_content("Holt, Steve")
      expect(find(".ShowAidRequest-callerPhone")).to have_content("(555) 555-5555")
      expect(find(".ShowAidRequest-callerAddress")).to have_content("517 W 20th St")
      expect(find(".ShowAidRequest-callerAddress")).to have_content("Richmond VA 23225")
      expect(find(".ShowAidRequest-persons")).to have_content("2 adults, 1 child")
      expect(find(".ShowAidRequest-notes")).to have_content("1 adult is diabetic")
      expect(find(".ShowAidRequest-specialRequests")).to have_content("A/C unit, microwave")

      expect(all(".FulfillmentList-fulfillmentItem").size).to eq(3)
      expect(all(".FulfillmentList-fulfillmentItem").all? { |i| i.text.include? "Pending" }).to be true
    end

    # User PACKER selects all fulfillments to work
    # - system prints fulfillment sheet for all 
    # - system moves fulfillments selected to packed
    # - system distinguishes between special fulfillments and basic fulfillments

    signing_in_as(packer_volunteer) do
      click_on "Packing"
sleep 1
      click_on "New packing slip"
      click_on "Basic fulfillments"
      all(".CreatePackingSlip-basicTable tbody tr input").each &:check
      click_on "Print and pack"
      expect(find(".ViewPackingSlip-table")).to have_content("milk, bread, bleach, soap")
      expect(find(".ViewPackingSlip-table")).to have_content("bread, soup, bleach, paper towels")
      expect(all(".ViewPackingSlip-table tbody tr").size).to eq(2)
    end

    # User DRIVER picks up this fulfillment and another, picks each in the delivery list, and submits them as a new delivery attached to him
    #   - delivery view shown with fufillment 1
    #   - fulfillment 1 is marked "on the way"
    #   - fulfillment 2 is marked "on the way"

    signing_in_as(driver_volunteer) do
      click_on "Make a delivery"
      expect(current_path).to eql(new_delivery_path)
      all(".delivery_fulfillments input").each &:check
      fill_in "Notes", with: "I'm driving today"

      click_on "Start delivery now"
    end
  end

  it "handles the happy path" do
    sign_in! driver_volunteer
    click_on "My deliveries"
    expect(current_path).to eql(my_deliveries_path)

    click_on "2 fulfillments started less than a minute ago"

    expect(all(".ViewDelivery-fulfillmentCard").size).to eql(2)
    click_on "100 E Main St, Richmond VA"
    click_on "Mark delivered"
    sleep 1
    expect(find(".ViewDelivery-successHeader")).to have_content("Delivered!")
    
    click_on "517 W 20th St , Richmond VA 23225"
    click_on "Mark delivered"
    sleep 1
    all(".ViewDelivery-successHeader").each { |e| expect(e).to have_content("Delivered!") }
  end

  scenario 'cancel a fulfillment with a delivery in progress' do
    signing_in_as(driver_volunteer) do
      click_on "My deliveries"
      expect(current_path).to eql(my_deliveries_path)
      click_on "2 fulfillments started less than a minute ago"

      expect(all(".ViewDelivery-fulfillmentCard").size).to eql(2)
    end

    signing_in_as(hotline_volunteer) do
      click_on "Holt, Steve"
      click_and_confirm! "Dismiss"
    end

    signing_in_as(driver_volunteer) do
      # should send a text!

      click_on "My deliveries"

      expect(current_path).to eql(my_deliveries_path)

      click_on "2 fulfillments started less than a minute ago"
      expect(all(".ViewDelivery-fulfillmentCard").size).to eql(2)
      click_on "100 E Main St, Richmond VA"
      click_on "Mark delivered"
      sleep 1
      expect(find(".ViewDelivery-successHeader")).to have_content("Delivered!")

      expect(find(".ViewDelivery-fulfillmentCard:first-child")).to have_content("Delivered!")
      expect(find(".ViewDelivery-fulfillmentCard:last-child")).to have_content("CANCELLED") 
    end
  end
end
