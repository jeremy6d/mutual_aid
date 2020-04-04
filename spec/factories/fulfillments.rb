FactoryBot.define do
  factory :fulfillment do
    fulfiller do 
      begin
        v = create :another_volunteer
      rescue
        binding.pry
      end
    end
    aid_request
    contents { "bread, socks, bleach" }
  end
end
