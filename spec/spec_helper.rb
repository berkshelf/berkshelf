$:.push File.join(File.dirname(__FILE__), '..')
$:.push File.join(File.dirname(__FILE__), '..', 'lib')

require 'simplecov'
require 'pp'

RSpec.configure do |config|
  config.before do
    Remy.clear_shelf!
  end
end

SimpleCov.start do
  add_filter 'spec/'
end

require 'remy'
