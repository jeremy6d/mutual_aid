FactoryBot.define do
  factory :packing_slip do
    creator { create :another_volunteer }
    fulfillments { create_list :fulfillment, fulfillment_ct }

    transient do
      fulfillment_ct { 10 }
    end
  end
end
