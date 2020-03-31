require 'rails_helper'

RSpec.describe AidRequest, type: :model do
  subject { FactoryBot.build :aid_request }
  
  it "removes blank indications" do
    subject.indications = ["", "diabetes", ""]
    expect(subject.indications).to contain_exactly("diabetes")
  end

  it "removes non number characters from phone" do
    subject.caller_phone_number = "+1 (804) 445 - 3015"
    expect(subject.caller_phone_number).to eq("8044453015")
  end

  it "identifies keywords in notes to elevate as indication" do
    subject.notes = "wgwgewEGdiabetesregseseg"
    subject.save
    expect(subject. indications).to include("diabetes")
  end

  it "processes supplies needed into needs records" do
    subject.supplies_needed = "bread, milk, soap, cheese whiz, gravy"
    subject.save
    expect(subject.reload.needs.count).to eql(5)
  end
end
