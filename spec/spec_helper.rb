$:.push File.join(File.dirname(__FILE__), '..')
$:.push File.join(File.dirname(__FILE__), '..', 'lib')

require 'simplecov'
require 'pp'

RSpec.configure do |config|
  config.after do
    KnifeCookbookDependencies.clean
  end
end

SimpleCov.start do
  add_filter 'spec/'
end

require 'knife_cookbook_dependencies'

def example_cookbook_from_path
  @example_cookbook_from_path ||= KnifeCookbookDependencies::Cookbook.new('example_cookbook', path: File.join(File.dirname(__FILE__), 'fixtures', 'cookbooks'))
end
