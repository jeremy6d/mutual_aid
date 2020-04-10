require 'rails_helper'

RSpec.describe Fulfillment, type: :model do
  subject { FactoryBot.build :fulfillment }
  
  it "must have an image attachment when contents list is empty" do
    subject.contents = ""
    subject.contents_sheet_image.attach io: File.open(Rails.root.join("spec", "contents_sheet.jpg")), 
                                        filename: "contents_sheet.jpg",
                                        content_type: 'image/jpeg'
    expect(subject).to be_valid
  end

  it "must have a contents list when image attachment is missing" do
    expect(subject).to be_valid
  end

  it "is invalid when neither a contents list nor attachment is present" do
    subject.contents = ""
    expect(subject).not_to be_valid
    expect(subject.errors[:base]).to include("Either a contents list or an image are required")
  end

  context "when part of a delivery" do
    let!(:delivery) { FactoryBot.create :delivery, fulfillments: [subject] }
    
    it "notifies the delivery when it's cancelled" do  
      subject.cancel!
      expect(delivery).to be_cancelled
    end

    context "and fulfillment is returned from a delivery attempt" do
      before do
        subject.delivery_notes.create note: "Couldn't deliver", delivery: delivery
        subject.return!
      end
      
      it { expect(subject).to be_returned }
      it { expect(subject).to be_packed }
      it { expect(subject.delivery_notes.pluck :note).to contain_exactly("Couldn't deliver") }
      it { expect(subject.delivery_notes.first.author).to eql(delivery.driver) }
    end
  end
end
