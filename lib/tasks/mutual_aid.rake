require 'csv'

namespace :mutual_aid do
  desc "Import CSV into database"
  task :import, [:path] => [:environment] do |t, args|
    puts "Importing from #{args[:path]}"
    table = CSV.parse(File.read(args[:path]), headers: false)
    table.each do |row|
      r = AidRequest.create created_at: Chronic.parse(row[1], content: :past),
                            updated_at: Time.now,
                            original_taker: Volunteer.first,
                            caller_first_name: row[3].split(" ").first,
                            caller_last_name: row[3].split(" ")[1],
                            caller_phone_number: row[3].scan(/\d/).join,
                            caller_address: row[4],
                            supplies_needed: row[5],
                            persons: row[6],
                            notes: [ row[7], 
                                     row[0], 
                                     "original taker: #{row[2]}" 
                                   ].join("\n")
      puts "import #{r.caller_name}"
    end
  end
end
