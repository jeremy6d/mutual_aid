class Volunteer
  has_many :approving_volunteers, inverse_of: :approved_by,
                                  foreign_key: 'approved_by_id',
                                  class_name: "Volunteer"


  belongs_to :approved_by, inverse_of: :approving_volunteers,
                           class_name: "Volunteer"
end

class AddApprovedAndPhoneNumberToVolunteer < ActiveRecord::Migration[6.0]
 def up
    add_reference :volunteers, :approved_by, foreign_key: { to_table: :volunteers }
    add_column :volunteers, :phone_number, :string

    Volunteer.all.each do |v|
      v.approved_by = Volunteer.first
      v.save
      v2 = Volunteer.find(v.id)
      puts "#{v2.full_name} approved by #{v2.approved_by&.full_name || 'EMPTY'}"
    end
    puts "Volunteers still unapproved: #{Volunteer.where(approved_by_id: nil).count}"
  end

  def down
    remove_reference :volunteers, :approved_by
    remove_column :volunteers, :phone_number
  end
end
