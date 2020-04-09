class ApprovalMailer < ApplicationMailer
  default from: 'do-not-reply@madrva.org'
  layout 'mailer'

  def approval_notification(volunteer)
    @volunteer = volunteer
    mail(to: @volunteer.email, subject: 'Your Richmond Mutual Aid account has been approved')
  end
end
