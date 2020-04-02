module AcceptanceHelpers
  def the_flash(mode)
    page.find(".Flash-#{mode.to_s.downcase}").text
  end

  def sign_in!(volunteer)
    visit new_volunteer_session_path
    fill_in "Email", with: volunteer.email
    fill_in "Password", with: "password"
    click_on "Sign in"
    expect(find(".Navbar-volunteerName")).to have_content(volunteer.full_name)
  end

  def sign_out!
    2.times { find(".Navbar-volunteerName").click }
    click_on "Sign out"
    expect(current_path).to eql(new_volunteer_session_path)
  end

  def signing_in_as(volunteer)
    sign_in! volunteer
    yield volunteer
    sign_out!
  end
end

RSpec.configure { |c| c.include AcceptanceHelpers, type: :system }
