class PackingSlip < ApplicationRecord
  belongs_to :creator, class_name: "Volunteer"
  has_many :fulfillments


  before_create { fulfillments.each &:pack! }
  before_save :set_creator_name, if: :creator_id_changed?

  def percentage_complete
    return 0 if fulfillments.terminal.count.zero?
    (fulfillments.terminal.count * 100) / fulfillments.count
  end

private
  def set_creator_name
    write_attribute :creator_name, creator&.full_name
  end

  def completed_fulfillments
    fulfillments.select { |f| f.terminal? || f.returned? }
  end
end
