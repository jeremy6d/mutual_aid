FactoryBot.define do
  factory :fulfillment do
    contents { "something good" }
    aid_request
    factory :random_fulfillment do
      aid_request { create :random_aid_request }
      contents do 
        rand(1..20).times.map do 
          Faker::Food.ingredients
        end.join(", ")
      end
    end

    trait :packed do
      fulfiller { create :another_volunteer }
      status { :packed }
    end

    trait :cancelled do
      fulfiller { create :another_volunteer }
      status { :cancelled }
      delivery
    end

    trait :on_the_way do
      fulfiller { create :another_volunteer }
      status { :on_the_way }
      delivery
    end

    trait :delivered do
      fulfiller { create :another_volunteer }
      status { :delivered }
      delivery
    end

    trait :cancelled do
      fulfiller { create :another_volunteer }
      status { :cancelled }
      delivery
    end
  end
end
