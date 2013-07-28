here = File.dirname(__FILE__)

require "#{here}/../lib/gta"
Dir["#{here}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.color_enabled = true
end
