class Fulfillment < ApplicationRecord
  has_logidze
  include AASM

  aasm column: :status, whiny_persistence: true do
    state :pending, initial: true
    state :packed, enter: Proc.new { self.delivery = nil }
    state :on_the_way
    state :delivered
    state :cancelled

    event :pack do
      transitions from: :pending, to: :packed
    end

    event :unpack do
      transitions from: :packed, to: :pending
    end

    event :pickup do
      transitions from: :packed, to: :on_the_way
    end

    event :deliver do
      transitions from: :on_the_way, to: :delivered
    end

    event :return do
      transitions from: :on_the_way, to: :packed
    end

    event :cancel do
      transitions from: %i(pending packed on_the_way), to: :cancelled
    end
  end

  TERMINAL_STATUSES = %i(cancelled delivered).freeze
  OUTSTANDING_STATUSES = (aasm.states.map(&:name) - TERMINAL_STATUSES).freeze

  has_many :notes, as: :noteable

  belongs_to :delivery, optional: true, inverse_of: :driver
  belongs_to :aid_request
  belongs_to :fulfiller, class_name: "Volunteer", 
                         inverse_of: :fulfillments_packed,
                         optional: true

  validates_uniqueness_of :public_id

  after_create { aid_request.start! unless aid_request.in_progress? }
  after_update do
    delivery.touch if delivery.present?
    aid_request.check_deliveries! if terminal?
  end

  scope :terminal, -> { where(status: TERMINAL_STATUSES) }
  scope :special, -> { where(special: true) }
  scope :outstanding, -> { where(status: OUTSTANDING_STATUSES) }

  before_create :set_public_id

  delegate :neighborhood, :caller_address, :caller_name, :persons, 
           :caller_phone_number, to: :aid_request

  def to_param
    set_public_id if public_id.blank?
    public_id
  end

  def self.from_param(param)
    find_by_public_id(param)
  end

  def set_public_id
    req_id = "#{"S" if special?}#{aid_request.id}"
    f_seq = if new_record?
      aid_request.fulfillments.count
    else
      aid_request.fulfillments.order(id: :asc).pluck(:id).index(id).to_i
    end
    f_id = ('A'..'Z').to_a.at(f_seq % 26)
    self.public_id = [req_id, f_id].join("-")
  end

  def to_s
    [ public_id, 
      contents
    ].reject(&:blank?).join(" - ")
  end

  def returned?
    packed? && notes.any?
  end

  def terminal?
    cancelled? || delivered?
  end
private

  def contents_provided
    unless contents_sheet_image.attached? || contents.present?
      errors.add :base, "Either a contents list or an image are required"
    end
  end

  def note_left?
    errors.add(:base, "You have to leave a note") if notes.empty?
  end
end
