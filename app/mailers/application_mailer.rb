class ApplicationMailer < ActionMailer::Base
  default from: 'do-not-reply@madrva.org'
  layout 'mailer'
  
protected
  def api
    @api ||= SibApiV3Sdk::SMTPApi.new
  end
end
