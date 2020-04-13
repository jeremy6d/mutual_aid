require 'rails_helper'

RSpec.feature "Authorization", type: :system do
  before do
    visit new_volunteer_registration_path
    within find('form#new_volunteer') do
      fill_in "First name", with: "George"
      fill_in "Last name", with: "Bluth"
      fill_in "Phone number", with:"555-444-3333"
      fill_in "Email", with: "gbluth@bluth.co"
      fill_in "volunteer[password]", with: "password"
      fill_in "volunteer[password_confirmation]", with: "password"

      click_on "Sign up"
    end
  end

  describe "without approval" do
    it "notifies about approval after sign up" do
      expect(the_flash(:notice)).to have_content("signed up successfully but your account has not been approved")
    end

    it "lands on the root page after sign up" do
      expect(current_path).to eql(root_path)
    end

    it "disallows access" do
      visit aid_requests_path 
      expect(current_path).to eql(new_volunteer_session_path)
    end
  end

  describe "with approval" do
    before do 
      Volunteer.last.update_attribute :approved_by_id, FactoryBot.create(:volunteer)
    end

    it "allows access" do
      visit aid_requests_path 
      expect(current_path).to eql(new_volunteer_session_path)
    end

    it "lands on aid requests index page after sign in" do
      sign_in! Volunteer.last
      expect(current_path).to eql(aid_requests_path)
    end
  end
end
