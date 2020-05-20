FactoryBot.define do
  factory :delivery do
    driver { create :another_volunteer }
    fulfillments { create_list :fulfillment, fulfillment_ct }

    transient do
      fulfillment_ct { 1 }
    end
  end
end
