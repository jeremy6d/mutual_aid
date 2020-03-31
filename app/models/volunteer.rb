class Volunteer < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable

  has_many :requests_taken, class_name: "AidRequest", 
                            inverse_of: :taken_by

  validates_presence_of :first_name, :last_name

  def full_name
    [first_name, last_name].join(" ")
  end

end
