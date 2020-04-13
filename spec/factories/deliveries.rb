FactoryBot.define do
  factory :delivery do
    driver { create :another_volunteer }
    notes { "I don't know what I was expecting." }
    fulfillments { create_list :fulfillment, fulfillment_ct }

    transient do
      fulfillment_ct { 1 }
    end
  end
end
