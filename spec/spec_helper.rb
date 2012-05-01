$:.push File.join(File.dirname(__FILE__), '..')
$:.push File.join(File.dirname(__FILE__), '..', 'lib')

require 'remy'
require 'pp'

RSpec.configure do |config|
  config.before do
    Remy.clear_shelf!
  end
end
