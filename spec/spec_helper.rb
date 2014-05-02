require 'rbcalc'
root = File.dirname(__FILE__)

#Dir[File.join(root,'support', '**','*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.color_enabled = true
  config.mock_with :rspec
  config.order = "random"
end