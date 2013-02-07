require 'rubygems'

require 'bundler'
require 'spork'
require 'vcr'

Spork.prefork do
  unless ENV['DRB']
    require 'simplecov'
    SimpleCov.start
  end

  require 'json_spec'
  require 'pp'
  require 'rspec'
  require 'webmock/rspec'

  APP_ROOT = File.expand_path('../../', __FILE__)
  ENV["BERKSHELF_PATH"] = File.join(APP_ROOT, "tmp", "berkshelf")
  ENV["BERKSHELF_CHEF_CONFIG"] = File.join(APP_ROOT, "tmp", "knife.rb")

  Dir[File.join(APP_ROOT, "spec/support/**/*.rb")].each {|f| require f}

  VCR.configure do |c|
    c.cassette_library_dir = File.join(File.dirname(__FILE__), 'fixtures', 'vcr_cassettes')
    c.hook_into :webmock
  end

  RSpec.configure do |config|
    config.include Berkshelf::RSpec::FileSystemMatchers
    config.include JsonSpec::Helpers
    config.include Berkshelf::RSpec::ChefAPI

    config.mock_with :rspec
    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.filter_run focus: true
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
      Berkshelf.cookbook_store = Berkshelf::CookbookStore.new(tmp_path.join("downloader_tmp"))
      Berkshelf.ui.mute!
    end

    config.after(:each) do
      Berkshelf.ui.unmute!
    end
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
    @example_cookbook_from_path ||= Berkshelf::Cookbook.new('example_cookbook', path: File.join(File.dirname(__FILE__), 'fixtures', 'cookbooks'))
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

  Berkshelf::RSpec::Knife.load_knife_config(File.join(APP_ROOT, 'spec/knife.rb'))
end

Spork.each_run do
  require 'berkshelf'
  require 'berkshelf/vagrant'

  if ENV['DRB']
    require 'simplecov'
    SimpleCov.start
  end
end
