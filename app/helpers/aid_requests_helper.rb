module AidRequestsHelper
  def status_badge_for(req)
    content_tag :span, class: "badge badge-#{status_color_for(req)}" do
      fa_icon status_icon_for(req), text: req.status.titleize
    end
  end

  def status_color_for(obj)
    status = obj.is_a?(AidRequest) ? obj.status : obj
    case status.to_s
    when "unfulfilled"
      "danger"
    when "in_progress"
      "warning"
    when "fulfilled"
      "success"
    when "dismissed"
      "dark"
    end
  end

  def header_class_for(obj)
    if obj.urgent? && !obj.terminal?
      'bg-danger text-white'
    elsif obj.call_back? && obj.unfulfilled?
      'bg-success text-white'
    elsif obj.call_back? && obj.in_progress? 
       'bg-warning text-dark'
    else  
      'bg-light text-black'
    end
  end

  def status_icon_for(obj)
    status = obj.is_a?(AidRequest) ? obj.status : obj
    icon = case status.to_s
    when "unfulfilled"
      "inbox"
    when "in_progress"
      "tasks"
    when "fulfilled"
      "check-square"
    when "dismissed"
      "ban"
    end
  end

  def status_filter
    params.fetch(:status, "all")
  end
end
