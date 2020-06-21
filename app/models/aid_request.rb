class AidRequest < ApplicationRecord
  has_logidze
  include AASM

  attr_accessor :needs_call_back

  INDICATIONS = %w(diabetes immunocompromised see_notes)

  aasm column: :status do
    state :call_back, initial: true
    state :in_progress #, after_enter: :create_fulfillments!
    state :complete
    state :dismissed, before_enter: :cancel_fulfillments!

    event :start do
      transitions from: :call_back, to: :in_progress
    end

    event :hold do
      transitions from: :in_progress, to: :call_back
    end

    event :complete do
      transitions from: :in_progress, to: :complete
    end

    event :dismiss do
      transitions from: [:call_back, :in_progress], to: :dismissed
    end
  end

  before_create :detect_indications_in_notes!
  before_save :perform_transitions, unless: :terminal?

  has_many :fulfillments, inverse_of: :aid_request
  has_many :deliveries, through: :fulfillments
  belongs_to :original_taker, class_name: "Volunteer", 
                              inverse_of: :requests_taken

  scope :prioritized, -> {
    order(urgent: :desc, created_at: :asc)
  }

  scope :outstanding, -> {
    where.not(status: %i(dismissed fulfilled))
  }

  scope :special_requests, -> {
    where.not(special_requests: ["", nil])
  }

  def volunteer_name
    original_taker&.full_name
  end

  def caller_name
    [caller_last_name, caller_first_name].reject(&:blank?).join(", ")
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

  def check_deliveries!
    complete! if fulfillments.all? { |f| f.cancelled? || f.delivered? }
  end

  def terminal?
    dismissed? || fulfilled?
  end

  def self.to_csv
    attributes = %w{id status created_at caller_name caller_address supplies_needed persons}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.find_each do |user|
        csv << attributes.map{ |attr| user.send(attr) }
      end
    end
  end

  def terminal?
    complete? || dismissed?
  end

  def needs_call_back?
    !!@needs_call_back
  end

private
  def cancel_fulfillments!
    fulfillments.each &:cancel!
  end

  def perform_transitions
    hold if needs_call_back? && in_progress?
    start unless needs_call_back? && call_back?
  end
end
