module AidRequestsHelper
  def status_badge_for(req)
    content_tag :span, class: "badge badge-#{status_color_for(req)}" do
      fa_icon status_icon_for(req), text: req.status.titleize
    end
  end

  def status_color_for(obj)
    status = obj.is_a?(AidRequest) ? obj.status : obj
    case status.to_s
    when "fresh", "packed"
      "info"
    when "call_back", "pending"
      "danger"
    when "in_progress", "on_the_way"
      "warning"
    when "complete", "delivered"
      "success"
    when "dismissed", "cancelled"
      "dark"
    end
  end

  def header_class_for(obj)
    if obj.urgent? && !obj.terminal?
      'bg-danger text-white'
    elsif obj.call_back?
      'bg-success text-white'
    elsif obj.in_progress? 
       'bg-warning text-dark'
    elsif obj.fresh?
      'bg-info text-dark'
    else  
      'bg-light text-black'
    end
  end

  def status_icon_for(obj)
    status = obj.is_a?(AidRequest) ? obj.status : obj
    icon = case status.to_s
    when "fresh"
      "cloud"
    when "call_back"
      "phone"
    when "in_progress"
      "tasks"
    when "complete"
      "check-square"
    when "dismissed"
      "ban"
    end
  end

  def status_filter
    params.fetch(:status, "all")
  end
end
