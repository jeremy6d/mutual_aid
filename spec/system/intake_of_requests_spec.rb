require 'rails_helper'

RSpec.feature "Intake of aid request", type: :system, headless: false do
  # Provision users for our script
  { hotline_volunteer: %w(Buster Bluth),
    packer_volunteer: %w(Gene Parmesean),
    driver_volunteer: %w(George Bluth),
    inventory_volunteer: %w(Trisha Thoon) }.each do |role, names|
    let!(role) do 
      FactoryBot.create :volunteer, first_name: names.first,
                                    last_name: names.last
    end
  end

  # Provision an existing request with a packed fulfillment
  let!(:older_request) do
    FactoryBot.create :aid_request, :packed, caller_first_name: "Lindsay",
                                             caller_last_name:  "Bluth",
                                             caller_address: "100 E Main St, Richmond VA"
  end

  it "handles the happy path", js: true do
    # User HOTLINE enters request 1 information and submits
    # - information is persisted to the database
    # - request is marked "unfulfilled"
    # - redirects to the new request form
    # - shows a flash saying message entered

    signing_in_as(hotline_volunteer) do
      click_on "New"

      fill_in "Caller first name", with: "Steve"
      fill_in "Caller last name", with: "Holt"
      fill_in "Caller phone number", with: "1-555-555-5555"
      fill_in "Caller address", with: "517 W 20th St\nRichmond VA 23225"
      fill_in "Supplies needed", with: "bread, soup, bleach, paper towels"
      fill_in "Persons", with: "2 adults, 1 child"
      fill_in "Notes", with: "1 adult is diabetic"

      click_on "Submit"

      expect(current_path).to eql(aid_request_path(AidRequest.last))
      expect(find(".ShowAidRequest-indicationsArea")).to have_content("DIABET")
      expect(find(".ShowAidRequest-callerName")).to have_content("Holt, Steve")
      expect(find(".ShowAidRequest-callerPhone")).to have_content("(555) 555-5555")
      expect(find(".ShowAidRequest-callerAddress")).to have_content("517 W 20th St")
      expect(find(".ShowAidRequest-callerAddress")).to have_content("Richmond VA 23225")
      expect(find(".ShowAidRequest-persons")).to have_content("2 adults, 1 child")
      expect(find(".ShowAidRequest-notes")).to have_content("1 adult is diabetic")
    end

    # User PACKER creates a fulfillment 1
    # - system should print a fulfillment sheet
    #   - sheet has map of location and streetview
    #   - sheet has details of request and fulfillment 1
    #   - sheet lists total number of bags
    #   - sheet displays unique id of request and fulfillment 1
    # - fufillment form should have all details for request available

    signing_in_as(packer_volunteer) do
      click_on "Holt, Steve"

      click_on "Fulfill"

      # expect(current_path).to eql(new_aid_request_fulfillment_path(AidRequest.last))
      expect(find(".FulfillAidRequest-indicationsArea")).to have_content("diabet")
      expect(find(".FulfillAidRequest-callerName")).to have_content("Holt, Steve")
      expect(find(".FulfillAidRequest-callerPhone")).to have_content("(555) 555-5555")
      expect(find(".FulfillAidRequest-persons")).to have_content("2 adults, 1 child")
      expect(find(".FulfillAidRequest-notes")).to have_content("1 adult is diabetic")

      attach_file "fulfillment[contents_sheet_image]", 
                  "spec/contents_sheet.jpg"
      fill_in "Notes", with: "Packed eggs separately"
      fill_in "Number of bags", with: "2"

      click_on "Ready for pickup"

      expect(current_path).to eql(aid_request_path(AidRequest.last))
      expect(the_flash(:notice)).to have_content("success")
      expect(find(".ShowAidRequest-status")).to have_content("In Progress")
      expect(all(".FulfillmentList-fulfillmentItem").first).to have_content("Packed")
    end

    # User DRIVER picks up this fulfillment and another, picks each in the delivery list, and submits them as a new delivery attached to him
    #   - delivery view shown with fufillment 1
    #   - fulfillment 1 is marked "on the way"
    #   - fulfillment 2 is marked "on the way"

    signing_in_as(driver_volunteer) do
      click_on "Make a delivery"

      expect(current_path).to eql(new_delivery_path)

      page.find("div.form-check", text: /100 E Main St/i).check
      page.find("div.form-check", text: /517 W 20th St/i).check

      click_on "Start delivery now"
    end

    signing_in_as(driver_volunteer) do
      click_on "My deliveries"
      expect(current_path).to eql(my_deliveries_path)

      click_on "2 fulfillments started less than a minute ago"

      expect(all(".ViewDelivery-fulfillmentCard").size).to eql(2)

      within(all(".ViewDelivery-fulfillmentCard").first) do
        click_on "Mark delivered"
        sleep 1
      end

      expect(all(".card-header").first).to have_content("Delivered!")
      expect(all(".card-header").last).not_to have_content("Delivered!")


      click_on "Mark delivered"
      sleep 1
      all(".card-header").each { |e| expect(e).to have_content("Delivered!") }
    end
  end

  it "marks a request as urgent" do
    sign_in! FactoryBot.create(:volunteer)
    click_on "New"
    info = FactoryBot.attributes_for(:random_aid_request, urgent: true)
    submit_aid_request_for(info)
    expect(find(".ShowAidRequest-urgent")).to be_visible
    click_on "Back"
    expect(all('tbody tr').first.matches_css?(".bg-danger")).to be true
  end
end
