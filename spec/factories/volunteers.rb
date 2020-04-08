NAMES = [ 'Oscar Bluth', 'Barry Zuckerkorn',
          'Maggie Lizer', 'Lucille Austero',
          'Steve Holt', 'Carl Weathers',
          'Marta Estrella', 'Rita Leeds',
          'Kitty Sanchez', 'Stan Sitwell',
          'Sally Sitwell', 'Moses Taylor',
          'Tony Wonder', 'Cindi Lightballoon',
          'Larry Middleman', 'Franklin Bluth',
          'JWalter Weatherman', 'Mort Meyers',
          'Stefan Gentles', 'Tom Saunders',
          'Trisha Thoon', 'Wayne Jarvis',
          'Rebel Alley', 'Trevor Leeds',
          'Argyle Austero', 'Marky Bark',
          'DeBrie Bardeaux', 'Herbert Love',
          'Ron Howard', 'China Garden',
          'Surely Woolfbeak', 'James Buck',
          'Phillip Litt', 'Frank Wrench',
          'Tracey Bluth', ' Earl Milford',
          'Charles Milford', 'Gammie Bluth' ]

FactoryBot.define do
  factory :volunteer do
    # approved_by { create :another_volunteer }
    first_name { "GOB" }
    last_name { "Bluth" }
    sequence(:email) { |i| "#{first_name}.#{last_name}-#{rand(99999)}#{i}@bluth.co" }
    password { "password" }
    password_confirmation { "password" }
    after(:create) { |v| v.approved_by = v; v.save }
    
    factory :another_volunteer do
      approved_by { create :volunteer }
      transient do
        names do
          NAMES.map { |n| n.split(" ") }
        end
      end

      sequence(:first_name) { |i| names[(names.size - 1) % i].first }
      sequence(:last_name)  { |i| names[(names.size - 1) % i].last  }
    end
  end
end
