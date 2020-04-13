class Note < ApplicationRecord
  belongs_to :noteable, polymorphic: true
  belongs_to :author, class_name: "Volunteer"

  validates_presence_of :body

  def author
    noteable.delivery.driver
  end
end
