FactoryBot.define do
  factory :fulfillment do
    fulfiller { create :another_volunteer }
    aid_request
  end
end
