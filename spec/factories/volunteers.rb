NAMES = [ 'Oscar Bluth', 'Barry Zuckerkorn',
          'Maggie Lizer', 'Lucille Austero',
          'Steve Holt', 'Carl Weathers',
          'Marta Estrella', 'Rita Leeds',
          'Kitty Sanchez', 'Stan Sitwell',
          'Sally Sitwell', 'Moses Taylor',
          'Tony Wonder', 'Cindi Lightballoon',
          'Larry Middleman', 'Franklin Bluth' ]

FactoryBot.define do
  factory :volunteer do
    first_name { "GOB" }
    last_name { "Bluth" }
    email { "#{first_name}#{last_name}@gobias.biz" }
    password { "password" }
    password_confirmation { "password" }
    
    factory :another_volunteer do
      transient do
        names do
          NAMES.map { |n| n.split(" ") } * 1000 
        end
      end

      sequence(:first_name) { |i| names[names.size % i].first }
      sequence(:last_name)  { |i| names[names.size % i].last  }
      sequence(:email) { |i| "#{first_name.downcase}#{last_name.downcase}-#{i}@bluth.co" }
    end
  end
end
