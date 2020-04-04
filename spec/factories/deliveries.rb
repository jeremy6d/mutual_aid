FactoryBot.define do
  factory :delivery do
    driver { create :another_volunteer }
    notes { "I don't know what I was expecting." }
    trait :packed do
      transient do
        fulfillment_ct { 1 }
      end

      after(:create) do |d, evaluator|
        create_list :fulfillment, evaluator.fulfillment_ct, delivery: d
      end
    end
  end
end
