module AcceptanceHelpers
  def the_flash(mode)
    page.find(".Flash-#{mode.to_s.downcase}").text
  end

  def sign_in!(volunteer)
    visit new_volunteer_session_path
    within("form#new_volunteer") do
      fill_in "Email", with: volunteer.email
      fill_in "Password", with: "password"
      click_on "Sign in"
    end
    expect(find(".Navbar-volunteerName")).to have_content(volunteer.full_name)
  end

  def sign_out!
    find(".Navbar-volunteerName").click
    click_on "Sign out"
    expect(current_path).to eql(root_path)
  end

  def signing_in_as(volunteer)
    sign_in! volunteer
    yield volunteer
    sign_out!
  end

  def submit_aid_request_for(info)
    fill_in "First name", with: info[:caller_first_name]
    fill_in "Last name", with: info[:caller_last_name]
    fill_in "Phone number", with: info[:caller_phone_number]
    fill_in "address", with: info[:caller_address]
    fill_in "Supplies needed", with: info[:supplies_needed]
    fill_in "Persons", with: info[:persons]
    fill_in "Notes", with: info[:notes]
    info[:indications].to_a.each do |i|
      check i
    end
    find('.aid_request_urgent .toggle-off').click if info[:urgent]
    find('.aid_request_call_back .toggle-off').click if info[:call_back]
    click_on "Submit"
  end

  def click_and_confirm!(button_title)
    page.accept_confirm do
      sleep 1
      click_on(button_title)
      sleep 1
    end
  end
end

RSpec.configure { |c| c.include AcceptanceHelpers, type: :system }
