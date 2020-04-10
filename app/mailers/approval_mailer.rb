class ApprovalMailer < ApplicationMailer
  def approval_notification(volunteer)
    @volunteer = volunteer
    mail  to: @volunteer.email, 
          subject: 'Your app.madrva.org account has been approved'
  end
end
