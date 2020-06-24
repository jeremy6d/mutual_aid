module PackingSlipsHelper
  def location_of(fulfillment)
    elements = [fulfillment.aid_request.caller_address]
    n = fulfillment.aid_request.neighborhood
    unless n.blank?
      elements.unshift "<strong>#{n}</strong>"
    end

    raw elements.reject(&:blank?).join("<br />")
  end
end
