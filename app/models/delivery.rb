class Delivery < ApplicationRecord
  class Status 
    ALL = %w(empty delivered on_the_way cancelled)
    ALL.each do |s|
      const_set s.upcase, s
    end
  end
  has_many :notes, as: :noteable

  has_many :fulfillments, dependent: :nullify,
                          after_remove: Proc.new { |_, obj| obj.reload.return! }

  belongs_to :driver, class_name: "Volunteer", 
                      inverse_of: :deliveries,
                      foreign_key: "driver_id"

  validates :fulfillments, length: { minimum: 1 }

  after_save do
    fulfillments.packed.each &:pickup!
  end
  before_save :update_status, :cache_neighborhoods!
  after_touch :update_status!
  after_initialize :update_status

  accepts_nested_attributes_for :notes, reject_if: Proc.new { |attrs| attrs[:body].blank? }

  def update_status!
    update_status and save!
  end

  scope :delivered, -> { where(status: Delivery::Status::DELIVERED) }
  scope :on_the_way, -> { where(status: Delivery::Status::ON_THE_WAY) }

  def destinations
    fulfillments.includes(:aid_requests).group_by(:aid_request_id)
  end

  def delivered?
    self.status == Delivery::Status::DELIVERED
  end

  def on_the_way?
    self.status == Delivery::Status::ON_THE_WAY
  end

  def empty?
    self.status == Delivery::Status::EMPTY
  end

  def cancelled?
    self.status == Delivery::Status::CANCELLED
  end

private
  def cache_neighborhoods!
    self.neighborhoods = fulfillments.
      map { |f| f.aid_request.neighborhood }.
      compact.
      map(&:titleize).
      map(&:strip).
      compact.
      uniq.
      to_sentence
  end

  def deliveries_complete?
    fulfillments.all? { |f| %w(cancelled delivered).include? f.status }
  end

  def update_status
    self.status = case 
    when fulfillments.empty?
      Status::EMPTY
    when fulfillments.all?(&:cancelled?)
      Status::CANCELLED
    when deliveries_complete?
      Status::DELIVERED
    else
      Status::ON_THE_WAY
    end
  end
end
