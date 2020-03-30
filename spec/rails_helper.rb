require 'spec_helper'
require 'webdrivers/chromedriver'
ENV['RAILS_ENV'] ||= 'test'
# ENV['RAILS_SYSTEM_TESTING_SCREENSHOT'] = 'inline'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

Capybara.register_driver :selenium_chrome_headless do |app|
  Capybara::Selenium::Driver.load_selenium
  browser_options = ::Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    opts.args << '--headless'
    opts.args << '--window-size=1920,1080'
    opts.args << '--disable-gpu' if Gem.win_platform?
    # Workaround https://bugs.chromium.org/p/chromedriver/issues/detail?id=2650&q=load&sort=-id&colspec=ID%20Status%20Pri%20Owner%20Summary
    opts.args << '--disable-site-isolation-trials'
  end
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.infer_base_class_for_anonymous_controllers = false
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.before(:each, type: :system) do
    driven_by :rack_test
  end
config.include Rails.application.routes.url_helpers
  config.before(:each, type: :system, js: true) do
    if ENV["SELENIUM_DRIVER_URL"].present?
      driven_by :selenium, using: :chrome,
                           options: {
                             browser: :remote,
                             url: ENV.fetch("SELENIUM_DRIVER_URL"),
                             desired_capabilities: :chrome
                           }
    else
      driven_by :selenium_chrome_headless
    end
  end

  config.before(:each, type: :system, headless: false) do
    driven_by :selenium_chrome
  end

  config.after(:each, type: :system, js: true) do
    logs = page.driver.browser.manage.logs.get(:browser)
    logs.each { |l| puts l }
  end
end
