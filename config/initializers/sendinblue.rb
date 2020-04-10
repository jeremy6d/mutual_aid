SibApiV3Sdk.configure do |config|
  config.api_key['api-key'] = Rails.application.credentials.sendinblue[:api_key]
end
