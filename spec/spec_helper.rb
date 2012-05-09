require 'rubygems'
require 'bundler'
require 'spork'
require 'test_ui'

Spork.prefork do
  require 'rspec'
  require 'simplecov'
  require 'pp'
  
  APP_ROOT = File.expand_path('../../', __FILE__)
  
  Dir[File.join(APP_ROOT, "spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|    
    config.mock_with :rspec
    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.filter_run :focus => true
    config.run_all_when_everything_filtered = true

    config.after do
      KnifeCookbookDependencies.clean
    end
  end

  SimpleCov.start do
    add_filter 'spec/'
  end

  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end

  def example_cookbook_from_path
    @example_cookbook_from_path ||= KnifeCookbookDependencies::Cookbook.new('example_cookbook', path: File.join(File.dirname(__FILE__), 'fixtures', 'cookbooks'))
  end

  def with_cookbookfile content
    Dir.chdir(ENV['TMPDIR']) do
      File.open('Cookbookfile', 'w') do |f|
        f.write content
      end
      yield
    end
  end

end

Spork.each_run do
  require 'knife_cookbook_dependencies'
end
