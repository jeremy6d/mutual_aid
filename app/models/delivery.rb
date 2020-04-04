class Delivery < ApplicationRecord
  class Status 
    ALL = %w(empty delivered on_the_way)
    ALL.each do |s|
      const_set s.upcase, s
    end
  end

  has_many :fulfillments
  belongs_to :driver, class_name: "Volunteer", 
                      inverse_of: :deliveries,
                      foreign_key: "driver_id"

  validates :fulfillments, length: { minimum: 1 }

  after_create do 
    fulfillments.each &:pickup!
  end

  before_save :update_status
  after_touch :update_status!
  after_initialize :update_status

  def update_status!
    update_status and save!
  end

  scope :delivered, -> { where(status: Delivery::Status::DELIVERED) }
  scope :on_the_way, -> { where(status: Delivery::Status::ON_THE_WAY) }

  def delivered?
    self.status == Delivery::Status::DELIVERED
  end

  def on_the_way?
    self.status == Delivery::Status::ON_THE_WAY
  end

private
  def update_status
    self.status = case 
    when fulfillments.empty?
      Status::EMPTY
    when fulfillments.all?(&:delivered?)
      Status::DELIVERED
    else
      Status::ON_THE_WAY
    end
  end
end
