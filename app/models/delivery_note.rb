class DeliveryNote < ApplicationRecord
  belongs_to :fulfillment
  belongs_to :delivery

  validates_presence_of :note

  def author
    delivery.driver
  end
end
