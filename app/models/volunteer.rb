class Volunteer < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable

  has_many :requests_taken, class_name: "AidRequest", 
                            inverse_of: :taken_by
  has_many :fulfillments_packed, inverse_of: :fulfillers, 
                                 foreign_key: 'fulfiller_id'
  has_many :deliveries, inverse_of: :driver, 
                        foreign_key: 'driver_id'

  validates_presence_of :first_name, :last_name

  def full_name
    [first_name, last_name].join(" ")
  end

end
