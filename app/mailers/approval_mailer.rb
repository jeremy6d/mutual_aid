class ApprovalMailer < ApplicationMailer

  def approval_notification(volunteer)
    @email = SibApiV3Sdk::SendSmtpEmail.new
    @email.sender = {
      name: "Richmond Mutual Aid Disaster Relief",
      email: "do-not-reply@madrva.org"
    }
    @email.to = [{ "email": volunteer.email }]
    @email.text_content = text(volunteer)
    @email.subject = "Your account at app.madrva.org has been approved"
    
    # Send your email
    api.send_transac_email(@email)
  end
private
  def text(volunteer)
    %Q~Your app.madrva.org account for #{volunteer.email} have been approved! Sign in here:

https://rvamutualaid.herokuapp.com/volunteers/sign-in~
  end
end
