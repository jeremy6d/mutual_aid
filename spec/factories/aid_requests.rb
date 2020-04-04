FactoryBot.define do
  factory :aid_request do
    caller_first_name { "Robert" }
    caller_last_name { "Loblaw" }
    original_taker { create :another_volunteer }
    indications { ["immunocompromised"] }
    caller_address {
      %Q~1203 Main St
      Richmond, VA~
    }
    caller_phone_number { "8042348765" }
    supplies_needed { "milk, bread, bleach, soap" }
    persons { "2 adults, 1 child" }
    notes { "Child suffers from diabetes" }

    trait :packed do
      transient do
        fulfillment_ct { 1 }
      end

      after(:create) do |r, evaluator|
        create_list :fulfillment, evaluator.fulfillment_ct, aid_request: r
      end
    end
  end
end
