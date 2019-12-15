Thread.report_on_exception = true

require 'minitest/autorun'
require 'capybara/minitest'
require 'webdrivers'
Capybara.run_server = false

Capybara.register_driver :chrome_headless do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: {
      args: %w(no-sandbox headless disable-gpu)
    }
  )

  Capybara::Selenium::Driver.new(app,
    browser: :chrome,
    desired_capabilities: capabilities
  )
end

Capybara.javascript_driver = :chrome_headless
Capybara.current_driver = :chrome_headless


class CGITest < Minitest::Test
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  def setup
    Capybara.current_driver = Capybara.javascript_driver
  end

  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end


# Here's the trick:
# We need to run the Webrick server in a separate thread so the
# testcases can make requests and block, waiting for the response.
WEBRICK = Thread.new do
  require 'webrick'

  server = WEBrick::HTTPServer.new(
    :Port => 8999,
    :DocumentRoot => File.expand_path("../..", __FILE__),
  )
  trap('INT') { server.shutdown }

  puts "Starting Webrick on port 8999"
  server.start
end

# Point Capybara to Webrick!
Capybara.app_host = 'http://localhost:8999'

# give webrick time to boot before the tests can run
sleep 1
