# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

if Volunteer.count.zero?
  admin = Volunteer.create! first_name: "Jeremy", 
                            last_name: "Weiland", 
                            password: "password",
                            password_confirmation: "password",
                            email: "jeremy@jeremyweiland.com"
  admin.approved_by = admin
  admin.save
end

20.times do 
  FactoryBot.create :random_aid_request
end
