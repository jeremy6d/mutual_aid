class Volunteer < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable

  has_many :requests_taken, class_name: "AidRequest", 
                            inverse_of: :original_taker
  has_many :fulfillments_packed, inverse_of: :fulfillers, 
                                 foreign_key: 'fulfiller_id',
                                 class_name: "Fulfillment"
  has_many :deliveries, inverse_of: :driver, 
                        foreign_key: 'driver_id'
  has_many :approving_volunteers, inverse_of: :approved_by,
                           foreign_key: 'approved_by_id',
                           class_name: "Volunteer"

  belongs_to :approved_by, inverse_of: :approving_volunteers,
                           class_name: "Volunteer",
                           optional: true


  validates_presence_of :first_name, :last_name

  before_save :send_approval_notification, if: Proc.new { |v| v.just_approved? }

  def full_name
    [first_name, last_name].join(" ")
  end

  def active_for_authentication? 
    super && approved? 
  end 
  
  def inactive_message 
    approved? ? super : :not_approved
  end

  def approved?
    [approved_by, ENV['SKIP_APPROVALS']].any?(&:present?)
  end

  def just_approved?
    old_id, new_id = changes["approved_by_id"]
    old_id.nil? && new_id.present?
  end

  def send_approval_notification
    ApprovalMailer.approval_notification(self).deliver
  end

  def settings
    OpenStruct.new({ use_google_voice: false })
  end
end
