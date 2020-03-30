module AidRequestsHelper
  def status_badge_for(req)
    content_tag :span, class: "badge badge-#{status_color_for(req)}" do
      fa_icon status_icon_for(req), text: req.status.titleize
    end
  end

  def status_color_for(req)
    case req.status
    when "unfulfilled"
      "primary"
    when "in_progress"
      "warning"
    when "fulfilled"
      "success"
    when "dismissed"
      "dark"
    end
  end

  def status_icon_for(req)
    icon = case req.status
    when "unfulfilled"
      "inbox"
    when "in_progress"
      "tasks"
    when "fulfilled"
      "check-square"
    when "dismissed"
      "times-octagon"
    end
  end
end
