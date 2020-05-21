FactoryBot.define do
  factory :fulfillment do
    fulfiller { create :another_volunteer }
    aid_request { create :random_aid_request }
    contents do 
      rand(1..20).times.map do 
        Faker::Food.ingredients
      end
    end
  end
end
