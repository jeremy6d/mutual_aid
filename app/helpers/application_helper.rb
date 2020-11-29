module ApplicationHelper
  def link_to_phone(number)
    full_number = "1#{number}" unless number.to_s[0] == "1"
    url = if current_volunteer.settings.use_google_voice
      "https://voice.google.com/u/0/calls?a=nc,%2B#{full_number}"
    else
      "tel:#{number}"
    end
    link_to url do
      fa_icon "phone", base: "google", text: number_to_phone(number, area_code: true)
    end
  end

  def status_icon_for(obj)
    icon = case status_for(obj)
    when "fresh"
      "headset"
    when "call_back"
      "phone"
    when "in_progress"
      "tasks"
    when "complete", "delivered"
      "check-square"
    when "dismissed", "cancelled"
      "ban"
    when "pending"
      "box-open"
    when "packed"
      "box"
    when "on_the_way"
      "people-carry"
    end
  end

  def status_badge_for(req)
    content_tag :span, class: "badge badge-#{status_color_for(req)}" do
      fa_icon status_icon_for(req), text: req.status.titleize
    end
  end

  def status_color_for(obj)
    case status_for(obj)
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

  def status_for(obj)
    return obj if obj.is_a?(String)
    return obj.to_s if obj.is_a?(Symbol)
    obj.status
  end
end
