class AidRequest < ApplicationRecord
  include AASM

  INDICATIONS = %w(diabetes immunocompromised see_notes)

  aasm column: :status do
    state :unfulfilled, initial: true
    state :in_progress
    state :complete
    state :dismissed

    event :start do
      transitions from: :new, to: :in_progress
    end

    event :complete do
      transitions from: :in_progress, to: :complete
    end

    event :dismiss do
      transitions from: [:new, :in_progress], to: :dismissed
    end
  end

  # has_many :needed_items
  belongs_to :original_taker, class_name: "Volunteer", 
                              inverse_of: :requests_taken

  def volunteer_name
    original_taker.full_name
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
    add_indications_for in_notes
    super in_notes
  end

  # def needed_items=(items)
  #   items.each do |i|
  #     needed_items.find_or_build_by(name: i)
  #   end
  # end

private
  def add_indications_for(txt)
    indications ||= []
    ["immun", "compromised"].each do |phrase|
      indications << "immunocompromised" if txt =~ /#{phrase}/i
    end
    ["diab", "diba", "betes", "betse", "bets"].each do |phrase|
      indications << "diabetes" if txt =~ /#{phrase}/i
    end
    indications = indications.uniq
  end
end
