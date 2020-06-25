# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

puts "--- Volunteers ---"
if Volunteer.count.zero?
  admin = Volunteer.create! first_name: "Jeremy", 
                            last_name: "Weiland", 
                            password: "password",
                            password_confirmation: "password",
                            email: "jeremy@jeremyweiland.com"
  admin.approved_by = admin
  puts "\t* Created #{admin.full_name}"
  admin.save
end

puts "--- Aid Requests ---"
20.times do |n|
  time = (20 - n).days.ago
  Timecop.travel(time) do
    ar = FactoryBot.create :random_aid_request
    puts "\t* Created aid request: #{ar.attributes.to_s}"
  end
end

puts "--- COMPLETE ---"
