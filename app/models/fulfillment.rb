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

  belongs_to :aid_request
  belongs_to :fulfiller, class_name: "Volunteer", 
                         inverse_of: :fulfillments

  has_one_attached :contents_sheet_image

  validate :contents_provided

  after_create { aid_request.start! }

private

  def contents_provided
    unless contents_sheet_image.attached? || contents.present?
      errors.add :base, "Either a contents list or an image are required"
    end
  end
end
