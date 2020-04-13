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
end
