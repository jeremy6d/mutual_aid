require 'rails_helper'

RSpec.describe PackingSlip, type: :model do
  let(:volunteer) do 
    FactoryBot.create :volunteer, first_name: "Marky", 
                                  last_name: "Bark" 
  end
  subject { FactoryBot.create :packing_slip, creator: volunteer }

  it "packs all fulfillments when created" do
    expect(subject.fulfillments.all?(&:packed?)).to be true
  end

  it "caches the creator's name" do
    expect(subject.creator_name).to eq("Marky Bark")
  end

  it "returns the percentage complete" do
    subject.fulfillments.first.pickup!
    subject.fulfillments[1].pickup!
    subject.fulfillments.first.deliver!
    subject.fulfillments.last.cancel!
    expect(subject.percentage_complete).to eq(20)
  end
end
