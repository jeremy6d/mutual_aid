require 'rails_helper'

RSpec.feature "Packing operations", type: :system, js: true, headless: false do
  # it "allows a fulfillment to be cancelled" do
  #   fulfillment = FactoryBot.create :fulfillment
  #   volunteer = FactoryBot.create(:volunteer)
  #   sign_in! volunteer
  #   click_on "Packing"
  #   click_on "Packed fulfillment (less than a minute old)"
  #   accept_confirm { click_on "Cancel" }

  #   expect(page).to have_content("cancelled")
  # end

  let(:volunteer) { FactoryBot.create(:volunteer) }
  let(:fulfillment_ids) do 
    all(".CreatePackingSlip-basicTable tbody tr").map { |r| 
      next unless matches = r.text.match(/#(\d{4})/)
      matches.captures.last.to_s 
    }.compact
  end

  before do
    FactoryBot.create :aid_request, urgent: true, supplies_needed: "food kit, cleaning kit, coffee", special_requests: "Housing"
    FactoryBot.create :aid_request, supplies_needed: "apples, pears", special_requests: "housing, oven, pots and pans"
    FactoryBot.create :aid_request, supplies_needed: "food kit, cleaning kit", special_requests: nil
    sign_in! volunteer
    click_on "Packing"
    click_on "New packing slip"
  end

  it "allows packer to fulfill a list of fulfillments" do
    expect(all(".CreatePackingSlip-basicTable tbody tr").size).to eq(7)
    expect(all(".CreatePackingSlip-fulfillmentRow.table-danger").size).to eq(2)

    click_on "Special fulfillments"
    expect(all(".CreatePackingSlip-basicTable tbody tr").size).to eq(4)

    click_on "Basic fulfillments"
    expect(all(".CreatePackingSlip-basicTable tbody tr").size).to eq(3)

    click_on "All fulfillments"
    expect(all(".CreatePackingSlip-fulfillmentRow").size).to eq(7)

    packed_ids = all(".CreatePackingSlip-basicTable tbody tr td:first-child").first(3).map do |e|
      e.check
      puts e.find("input")[:id]
      e.text
    end
    fill_in "Remarks", with: "Let's go get it!"
    click_on "Print and pack"
    unpacked_ids = Fulfillment.all.map do |f| 
      f.public_id unless packed_ids.include?(f.public_id)
    end.compact
    within(find(".ViewPackingSlip-table tbody")) do
      expect(all("tr").size).to eq(3)
      packed_ids.each { |id| expect(page).to have_content(id) }
      unpacked_ids.each { |id| expect(page).not_to have_content(id) }
      expect(page).not_to have_content("PENDING")
      expect(page).to have_content("PACKED")
    end
  end
end
