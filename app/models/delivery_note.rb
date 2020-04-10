class DeliveryNote < ApplicationRecord
  belongs_to :fulfillment
  belongs_to :delivery

  validates_presence_of :notes

  def author
    delivery.driver
  end
end
