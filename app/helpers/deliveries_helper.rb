module DeliveriesHelper
  def delivery_badge_for(delivery)
    content_tag :span, class: "badge badge-#{delivery_color_for(delivery)}" do
      fa_icon delivery_icon_for(delivery), text: delivery.status.titleize
    end
  end

  def delivery_color_for(delivery)
    case delivery.status
    when Delivery::Status::EMPTY
      'danger'
    when Delivery::Status::ON_THE_WAY
      'warning'
    when Delivery::Status::CANCELLED
      'dark'
    when Delivery::Status::DELIVERED
      'success'
    end
  end

  def delivery_icon_for(delivery)
    case delivery.status
    when Delivery::Status::EMPTY
      'box-open'
    when Delivery::Status::ON_THE_WAY
      'shipping-fast'
    when Delivery::Status::CANCELLED
      'ban'
    when Delivery::Status::DELIVERED
      'clipboard-check'
    end
  end

  def recipient_names(delivery)
    links = delivery.fulfillments.map do |f|
      pid = "(#{f.public_id})"
      title = [f.aid_request.caller_name, pid].join(" ")
      link_to title, f.aid_request
    end
    links.to_sentence
  end

  def location_list(delivery)
    delivery.fulfillments.
              map { |f| f.aid_request.neighborhood&.titleize.strip }.
              uniq.
              to_sentence
  end

  def summary_of(delivery)
    delivery_ct = delivery.fulfillments.count
    locations = location_list(delivery)
    "#{delivery_ct} deliveries going to #{locations}"
  end
end
