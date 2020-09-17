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
    names = delivery.fulfillments.map do |f|
      [ f.aid_request.caller_last_name,
        link_to("(#{f.public_id})", f.aid_request) 
      ].join(" ")
    end
    raw names.to_sentence
  end

  def location_list(delivery)
    delivery.fulfillments.
              map { |f| f.aid_request.neighborhood }.
              compact.
              map(&:titleize).
              map(&:strip).
              compact.
              uniq.
              to_sentence
  end

  def summary_of(delivery)
    delivery_ct = delivery.fulfillments.count
    locations = location_list(delivery)
    a = "#{delivery_ct} deliveries" 
    b = locations.empty? ? nil : "going to #{locations}" 
    [a,b].compact.join(" ")
  end

  def en_route_summary_of(delivery)
    en_route_ct = delivery.fulfillments.on_the_way.count
    done_ct = delivery.fulfillments.count - en_route_ct
    a = "#{done_ct}/#{delivery.fulfillments.count} delivered"
    b = locations.empty? ? nil : "going to #{locations}" 
    [a,b].join(" ")
  end

  def searchable_data_for(req)
    %i(id caller_name neighborhood caller_address).
      map { |f| req.send(f).to_s.strip.downcase.gsub(/[^0-9a-z ]/i, '') }.
      join(' ')
  end
end
