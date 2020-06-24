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
      transitions from: :on_the_way, to: :packed, guard: Proc.new { notes.any? }
    end

    event :cancel do
      transitions to: :cancelled
    end
  end

  has_many :notes, as: :noteable

  belongs_to :delivery, optional: true, inverse_of: :driver
  belongs_to :aid_request
  belongs_to :fulfiller, class_name: "Volunteer", 
                         inverse_of: :fulfillments_packed,
                         optional: true

  # has_one_attached :contents_sheet_image

  # validate :contents_provided

  after_create { aid_request.start! unless aid_request.in_progress? }
  after_update do
    delivery.touch if delivery.present?
    aid_request.check_deliveries! if delivered?
  end

  scope :terminal, -> { where(status: %w(cancelled delivered)) }
  scope :special, -> { where(special: true) }

  before_save :set_public_id

  def set_public_id
    req_id = "##{"S" if special?}#{aid_request.id}"
    f_id = ('A'..'Z').to_a.at(aid_request.fulfillments.count % 26)
    self.public_id = [req_id, f_id].join("-")
  end

  def to_s
    [ public_id, 
      aid_request.caller_address&.gsub('\n', ', '), 
      (aid_request.neighborhood unless aid_request.neighborhood.blank?)
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
