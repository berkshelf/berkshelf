require 'rubygems'
require 'bundler'
require 'spork'
require 'vcr'

Spork.prefork do
  require 'rspec'
  require 'simplecov'
  require 'pp'
  
  APP_ROOT = File.expand_path('../../', __FILE__)
  
  Dir[File.join(APP_ROOT, "spec/support/**/*.rb")].each {|f| require f}

  VCR.configure do |c|
    c.cassette_library_dir = File.join(File.dirname(__FILE__), 'fixtures', 'vcr_cassettes')
    c.hook_into :webmock
  end

  RSpec.configure do |config|
    config.include KnifeCookbookDependencies::RSpec::FileSystemMatchers
    
    config.mock_with :rspec
    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.filter_run :focus => true
    config.run_all_when_everything_filtered = true

    config.around do |example|
      # Dynamically create cassettes based on the name of the example
      # being run. This creates a new cassette for every test.
      cur = example.metadata
      identifiers = [example.metadata[:description_args]]
      while cur = cur[:example_group] do
        identifiers << cur[:description_args]
      end

      VCR.use_cassette(identifiers.reverse.join(' ')) do
        example.run
      end
    end

    config.before(:each) do
      clean_tmp_path
      KCD.cookbook_store = KCD::CookbookStore.new(tmp_path.join("downloader_tmp"))
    end

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
    @example_cookbook_from_path ||= KCD::Cookbook.new('example_cookbook', path: File.join(File.dirname(__FILE__), 'fixtures', 'cookbooks'))
  end

  def app_root_path
    Pathname.new(APP_ROOT)
  end

  def tmp_path
    app_root_path.join('spec/tmp')
  end

  def fixtures_path
    app_root_path.join('spec/fixtures')
  end

  def clean_tmp_path
    FileUtils.rm_rf(tmp_path)
    FileUtils.mkdir_p(tmp_path)
  end
end

Spork.each_run do
  require 'kcd'
end
