class ApprovalMailer < ApplicationMailer
  default from: 'richmondmutualaid@protonmail.com'
  layout 'mailer'

  def approval_notification(volunteer)
    @volunteer = volunteer
    mail(to: @volunteer.email, subject: 'Your Richmond Mutual Aid account has been approved')
  end
end
