  class AidRequest < ApplicationRecord
  has_logidze
  include AASM

  INDICATIONS = %w(diabetes immunocompromised see_notes)

  aasm column: :status do
    state :unfulfilled, initial: true
    state :in_progress
    state :fulfilled
    state :dismissed

    event :start do
      transitions from: :unfulfilled, to: :in_progress
    end

    event :complete do
      transitions from: :in_progress, to: :fulfilled
    end

    event :dismiss do
      transitions from: [:unfulfilled, :in_progress], to: :dismissed
    end
  end

  before_create :detect_indications_in_notes!

  has_many :fulfillments, inverse_of: :fulfiller
  belongs_to :original_taker, class_name: "Volunteer", 
                              inverse_of: :requests_taken

  def volunteer_name
    original_taker&.full_name
  end

  def caller_name
    [caller_last_name, caller_first_name].join(", ")
  end

  def indications=(set)
    to_write = set.map(&:downcase).map(&:strip) & INDICATIONS
    super to_write
  end

  def caller_phone_number=(in_num)
    num_array = in_num.scan(/\d/)
    num_array.shift if num_array.first == "1"
    super num_array.join
  end

  def notes=(in_notes)
    super in_notes
  end

  def detect_indications_in_notes!
    detected = []
    ["immun", "comprom"].each do |txt|
      detected << "immunocompromised" if self.notes =~ /#{txt}/i
    end
    ["diab", "diba", "betes", "betse", "bets", "btci", "betci", "beti"].each do |txt|
      detected << "diabetes" if self.notes =~ /#{txt}/i
    end
    self.indications = (self.indications + detected).uniq
  end

  # def needed_items=(items)
  #   items.each do |i|
  #     needed_items.find_or_build_by(name: i)
  #   end
  # end
end
