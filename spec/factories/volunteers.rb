FactoryBot.define do
  factory :volunteer do
    first_name { "GOB" }
    last_name { "Bluth" }
    email { "gob@gobias.biz" }
    password { "password" }
    password_confirmation { "password" }
  end
end
