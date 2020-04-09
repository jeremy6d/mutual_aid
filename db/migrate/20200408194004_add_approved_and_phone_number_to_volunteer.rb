class Volunteer
  has_many :approving_volunteers, inverse_of: :approved_by,
                                  foreign_key: 'approved_by_id',
                                  class_name: "Volunteer"


  belongs_to :approved_by, inverse_of: :approving_volunteers,
                           class_name: "Volunteer"
end

APPROVER = Volunteer.first

class AddApprovedAndPhoneNumberToVolunteer < ActiveRecord::Migration[6.0]
 def change
    add_reference :volunteers, :approved_by, foreign_key: { to_table: :volunteers }
    add_column :volunteers, :phone_number, :string

    Volunteer.all.each do |v|
      v.approved_by = APPROVER
      puts "#{v.full_name} approved by #{APPROVER.full_name}"
    end
  end
end
