class Fulfillment < ApplicationRecord
  has_logidze
  include AASM

  aasm column: :status do
    state :packed, initial: true
    state :on_the_way
    state :delivered

    event :pickup do
      transitions from: :packed, to: :on_the_way
    end

    event :deliver do
      transitions from: :on_the_way, to: :delivered
    end

    event :return do
      transitions from: :on_the_way, to: :packed
    end
  end

  belongs_to :delivery, optional: true, inverse_of: :driver
  belongs_to :aid_request
  belongs_to :fulfiller, class_name: "Volunteer", 
                         inverse_of: :fulfillments_packed

  has_one_attached :contents_sheet_image

  validate :contents_provided

  after_create { aid_request.start! }
  after_update do 
    delivery.touch if delivery.present?
    aid_request.check_deliveries! if delivered?
  end

  def public_id
    "##{aid_request.id}F#{'%03d' % id}"
  end

  def to_s
    "#{public_id}: #{aid_request.caller_address.gsub('\n', ', ')}"
  end

private

  def contents_provided
    unless contents_sheet_image.attached? || contents.present?
      errors.add :base, "Either a contents list or an image are required"
    end
  end
end
