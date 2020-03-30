class CreateAidRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :aid_requests do |t|
      t.string :volunteer_name
      t.string :caller_first_name
      t.string :caller_last_name
      t.string :caller_phone_number
      t.string :status
      t.text :caller_address
      t.text :supplies_needed
      t.text :persons
      t.text :notes
      t.string :indications, array: true, default: []

      t.timestamps
    end
  end
end
