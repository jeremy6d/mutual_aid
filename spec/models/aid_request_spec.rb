require 'rails_helper'

RSpec.describe AidRequest, type: :model do
  subject { FactoryBot.build :aid_request }

  it "starts as a fresh" do
    expect(subject).to be_fresh
  end

  describe "on save if call back not toggled" do
    before do 
      subject.needs_call_back = false
      subject.save
    end

    it { expect(subject).to be_in_progress }
    it { expect(subject.fulfillments.count).to eq(3) }
  end

  describe "creating special fulfillments" do
    before do 
      subject.special_requests = "one, two"
      subject.supplies_needed = ""
      subject.save
    end

    it { expect(subject.fulfillments.special.count).to eq(2) }
    it { expect(subject.fulfillments.count).to eq(2) }
    it 'recognizes when an aid request is complete' do
      subject.fulfillments.first.cancel!
      subject.fulfillments.last.pack!
      subject.fulfillments.last.pickup!
      subject.fulfillments.last.deliver!
      subject.reload

      expect(AidRequest.outstanding).not_to include(subject)
    end
  end

  it "saves as call_back if call back toggled" do
    subject.needs_call_back = true
    subject.save
    expect(subject).to be_call_back
  end

  it "updates as call_back if call back toggled" do
    subject.save
    assert(subject.in_progress?)
    subject.needs_call_back = true
    subject.save
    expect(subject).to be_call_back
  end
  
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

  it "keeps it in call back if there's no way to fulfill it and needs_call_back not toggled" do
    subject.special_requests = subject.supplies_needed = ""
    subject.needs_call_back
    subject.save
    expect(subject).to be_call_back
  end

  it "defaults urgency to false" do
    expect(subject).not_to be_urgent
  end

  context "upon dismissal" do
    subject! { FactoryBot.create :aid_request, :packed }
    let!(:fulfillment) { FactoryBot.create :fulfillment }
    let!(:delivery) { FactoryBot.create :delivery, fulfillments: Fulfillment.all }

    it "marks all fulfillments cancelled" do
      subject.dismiss!
      expect(subject.fulfillments.pluck(:status).uniq).to contain_exactly("cancelled")
    end
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
