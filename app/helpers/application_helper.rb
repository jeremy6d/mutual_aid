module ApplicationHelper
  def link_to_google_voice(number)
    full_number = "1#{number}" unless number.to_s[0] == "1"
    link_to "https://voice.google.com/u/0/calls?a=nc,%2B#{full_number}" do
      fa_icon "phone", base: "google", text: number_to_phone(number, area_code: true)
    end
  end
end
