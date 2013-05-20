require 'rspec'
require_relative '../lib/lazy_stream'

RSpec.configure do |config|
  config.color_enabled = true
  config.formatter     = 'documentation'
end
