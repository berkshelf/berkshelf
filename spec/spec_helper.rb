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

def example_cookbook_from_path
  @example_cookbook_from_path ||= Remy::Cookbook.new('example_cookbook', path: File.join(File.dirname(__FILE__), 'fixtures', 'cookbooks', 'example_cookbook'))
end
