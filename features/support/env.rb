require 'rubygems'
require 'bundler'
Bundler.setup
require 'spork'

Spork.prefork do
  require 'rspec'
  require 'pp'
  require 'aruba/cucumber'
  require 'vcr'

  APP_ROOT = File.expand_path('../../../', __FILE__)

  ENV["BOOKSHELF_PATH"] = File.join(APP_ROOT, "tmp", "bookshelf")
  
  Dir[File.join(APP_ROOT, "spec/support/**/*.rb")].each {|f| require f}

  After do
    KCD.clean
  end

  Around do |scenario, block|
    VCR.use_cassette(scenario.title) do
      block.call
    end
  end

  Before do
    clean_cookbook_store
    @aruba_io_wait_seconds = 5
  end

  Before('@slow_process') do
    @aruba_io_wait_seconds = 10
  end

  def cookbook_store
    Pathname.new(ENV["BOOKSHELF_PATH"])
  end

  def clean_cookbook_store
    FileUtils.rm_rf(cookbook_store)
    FileUtils.mkdir_p(cookbook_store)
  end
end

Spork.each_run do
  require 'kcd'
end
