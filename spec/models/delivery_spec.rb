require 'rails_helper'

RSpec.describe Delivery, type: :model do
  subject do 
    FactoryBot.create :delivery, fulfillment_ids: fulfillments.map(&:id)
  end

  let(:fulfillments) do
    3.times.map { |n| FactoryBot.create(:fulfillment) }
  end

  it "starts out as empty" do
    expect(Delivery.new).to be_empty
  end

  it "disallows creation without at least one fulfillment" do
    delivery = FactoryBot.build(:delivery, fulfillments: [])
    expect(delivery).not_to be_valid
    expect(delivery.errors[:fulfillments]).not_to be_empty
  end

  context "determining status" do
    before do
      subject.fulfillments.each &:reload
    end

    it "registers as on_the_way when at least one fulfillment is on_the_way" do
      subject.fulfillments.first.deliver!
      subject.fulfillments.last.deliver!

      expect(subject).to be_on_the_way
    end

    it "registers as delivered when all fulfillments are delivered" do
      subject.fulfillments.each &:deliver!
      expect(subject.reload).to be_delivered
    end
  end
end 
