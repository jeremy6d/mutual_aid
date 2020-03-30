module AidRequestsHelper
  def status_badge_for(req)
    content_tag :span, class: "badge badge-#{status_color_for(req)}" do
      fa_icon status_icon_for(req), text: req.status.titleize
    end
  end

  def status_color_for(req)
    case req.status
    when "new"
      "default"
    when "picked"
      "info"
    when "packed"
      "primary"
    when "shipped"
      "warning"
    when "delivered"
      "danger"
    when "dismissed"
      "dark"
    end
  end

  def status_icon_for(req)
    icon = case req.status
    when "new"
      "tasks"
    when "picked"
      "box-open"
    when "packed"
      "box-closed"
    when "shipped"
      "shipping-fast"
    when "delivered"
      "check-square"
    when "dismissed"
      "times-octagon"
    end
  end
end
