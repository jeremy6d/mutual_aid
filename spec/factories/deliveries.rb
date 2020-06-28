FactoryBot.define do
  factory :delivery do
    driver { create :another_volunteer }
    fulfillments do 
      ar = create :aid_request
      ar.fulfillments.each &:pack!
      ar.fulfillments
    end

    transient do
      fulfillment_ct { 1 }
    end
  end
end
