NAMES = [ 'Oscar Bluth', 
          'Barry Zuckerkorn',
          'Maggie Lizer',
          'Lucille Austero',
          'Steve Holt',
          'Carl Weathers',
          'Marta Estrella',
          'Rita Leeds',
          'Kitty Sanchez',
          'Stan Sitwell',
          'Sally Sitwell',
          'Moses Taylor',
          'Tony Wonder',
          'Cindi Lightballoon' ]

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
          NAMES.map do |n| 
            n.split(" ")
          end
        end
      end

      sequence(:first_name) { |i| names[i - 1].first }
      sequence(:last_name)  { |i| names[i - 1].last  }
      email { "#{first_name.downcase}#{last_name.downcase}@bluth.co" }
    end
  end
end
