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

    factory :random_aid_request do
      caller_first_name { Faker::Name.first_name }
      caller_last_name { Faker::Name.last_name }
      caller_address { Faker::Address.full_address }
      caller_phone_number { Faker::PhoneNumber.cell_phone }
      indications { AidRequest::INDICATIONS.sample(rand(0..2)) }
      supplies_needed { rand(1..5).times.collect { Faker::Food.ingredient }.join(", ") }
      persons { "#{rand(1..3)} #{%w(adults children seniors).sample}" }
      notes { Faker::Lorem.sentences(number: rand(1..4)).join("\n") }
      transient do
        fulfillment_ct { rand(1..3) }
      end
    end

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
