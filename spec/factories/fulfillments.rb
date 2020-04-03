FactoryBot.define do
  factory :fulfillment do
    fulfiller { create :another_volunteer }
    aid_request
    contents { "bread, socks, bleach" }
  end
end
