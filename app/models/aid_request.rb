class AidRequest < ApplicationRecord
  include AASM

  INDICATIONS = %w(diabetes immunocompromised)

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

  # before_create :scan_for_indications

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
    scan_for_indications
    super
  end

private
  def scan_for_indications
    ["immun", "compromised"].each do |phrase|
      indications << "immunocompromised" if notes =~ /#{phrase}/i
    end
    ["diab", "diba", "betes", "betse", "bets"].each do |phrase|
      indications << "diabetes" if notes =~ /#{phrase}/i
    end
    indications.uniq!
  end
end
