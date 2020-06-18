require 'rails_helper'

RSpec.describe Fulfillment, type: :model do
  subject { FactoryBot.build :fulfillment }

  # it "must have an image attachment when contents list is empty" do
  #   subject.contents = ""
  #   subject.contents_sheet_image.attach io: File.open(Rails.root.join("spec", "contents_sheet.jpg")), 
  #                                       filename: "contents_sheet.jpg",
  #                                       content_type: 'image/jpeg'
  #   expect(subject).to be_valid
  # end

  # it "must have a contents list when image attachment is missing" do
  #   expect(subject).to be_valid
  # end

  # it "is invalid when neither a contents list nor attachment is present" do
  #   subject.contents = ""
  #   expect(subject).not_to be_valid
  #   expect(subject.errors[:base]).to include("Either a contents list or an image are required")
  # end

  it "starts out as ready_to_start" do
    expect(subject).to be_ready_to_start
  end

  context "when part of a delivery" do
    before { subject.pack! }
  
    let!(:delivery) { FactoryBot.create :delivery, fulfillments: [subject] }

    it { expect(subject.reload).to be_on_the_way }
    
    it "notifies the delivery when it's cancelled" do  
      subject.cancel!
      expect(delivery).to be_cancelled
    end

    it "disallows returning without a note" do
      assert subject.notes.empty?
      expect(subject.may_return?).to be false
    end

    context "and fulfillment is returned from a delivery attempt" do
      before do
        subject.notes.create body: "Couldn't deliver", author: delivery.driver
        assert subject.delivery.present?
        subject.reload.return!
      end

      let(:fulfillment) { subject.reload }
      let(:notes) { fulfillment.notes }
      
      it { expect(fulfillment).to be_returned }
      it { expect(fulfillment).to be_packed }
      it { expect(fulfillment).to be_returned }
      it { expect(fulfillment).to be_packed }
      it { expect(notes.pluck :body).to contain_exactly("Couldn't deliver") }
      it { expect(fulfillment.delivery).to be_nil }
    end
  end
end
