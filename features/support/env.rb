require 'rubygems'
require 'bundler'
require 'spork'

Spork.prefork do
  require 'rspec'
  require 'pp'
  require 'aruba/cucumber'
  require 'vcr'

  APP_ROOT = File.expand_path('../../../', __FILE__)

  ENV["BERKSHELF_PATH"] = File.join(APP_ROOT, "tmp", "berkshelf")

  begin
    CONFIG = YAML.load(File.read(File.join(APP_ROOT, "features", "config.yml")))
  rescue Errno::ENOENT
    raise "Please create a config file at features/config.yml from the sample found at features/config.sample.yml"
  end
  
  Dir[File.join(APP_ROOT, "spec/support/**/*.rb")].each {|f| require f}

  Around do |scenario, block|
    VCR.use_cassette(scenario.title) do
      block.call
    end
  end

  Before do
    Chef::Config[:chef_server_url] = CONFIG['chef_server_url']
    Chef::Config[:client_key] = CONFIG['client_key']
    Chef::Config[:node_name] = CONFIG['node_name']
    clean_cookbook_store
    @aruba_io_wait_seconds = 5
    @aruba_timeout_seconds = 5
  end

  Before('@slow_process') do
    @aruba_timeout_seconds = 15
    @aruba_io_wait_seconds = 10
  end

  def cookbook_store
    Pathname.new(ENV["BERKSHELF_PATH"])
  end

  def clean_cookbook_store
    FileUtils.rm_rf(cookbook_store)
    FileUtils.mkdir_p(cookbook_store)
  end

  def app_root_path
    Pathname.new(APP_ROOT)
  end

  def fixtures_path
    app_root_path.join('spec/fixtures')
  end
end

Spork.each_run do
  require 'berkshelf'
end
