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
    expect(subject.indications).to include("diabetes")
  end

  it "defaults urgency to false" do
    expect(subject).not_to be_urgent
  end

  context "priority queue" do
    let!(:oldest_request) do
      FactoryBot.create :random_aid_request, created_at: 2.days.ago
    end

    let!(:other_request) do
      FactoryBot.create :random_aid_request, created_at: 1.day.ago
    end

    before do  
      subject.urgent = true
      subject.save
    end
    
    it { expect(AidRequest.prioritized[0]).to eql(subject) }
    it { expect(AidRequest.prioritized[1]).to eql(oldest_request) }
    it { expect(AidRequest.prioritized[2]).to eql(other_request) }
  end
end
