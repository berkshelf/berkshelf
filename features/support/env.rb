require 'spork'

Spork.prefork do
  # This must be set BEFORE any require 'berkshelf' calls are made!
  ENV['RUBY_ENV'] = 'test'

  require 'aruba/cucumber'
  require 'aruba/in_process'
  require 'aruba/spawn_process'
  require 'cucumber/rspec/doubles'

  require 'berkshelf'
  require 'berkshelf/cli'

  Dir['spec/support/**/*.rb'].each { |f| require File.expand_path(f) }

  World(Berkshelf::RSpec::PathHelpers)
  World(Berkshelf::RSpec::Kitchen)

  Before do
    Aruba::InProcess.main_class = Berkshelf::Main
    Aruba.process = Aruba::InProcess

    stub_kitchen!
    purge_store_and_configs!

    @aruba_io_wait_seconds = Cucumber::JRUBY ? 7 : 5
    @aruba_timeout_seconds = Cucumber::JRUBY ? 35 : 15
  end

  Before('@spawn') do
    Aruba.process = Aruba::SpawnProcess

    # Legacy ENV variables until we can move over to all InProcess
    ENV['BERKSHELF_PATH'] = berkshelf_path.to_s
    ENV['BERKSHELF_CONFIG'] = Berkshelf.config.path.to_s
    ENV['BERKSHELF_CHEF_CONFIG'] = chef_config_path.to_s

    set_env('BERKSHELF_PATH', berkshelf_path.to_s)
    set_env('BERKSHELF_CONFIG', Berkshelf.config.path.to_s)
    set_env('BERKSHELF_CHEF_CONFIG', chef_config_path.to_s)
  end

  Before('@slow_process') do
    @aruba_io_wait_seconds = Cucumber::JRUBY ? 70 : 30
    @aruba_timeout_seconds = Cucumber::JRUBY ? 140 : 60
  end

  # Chef Zero
  require 'chef_zero/server'
  @server = ChefZero::Server.new(port: 4000)
  @server.start_background

  at_exit do
    @server.stop if @server && @server.running?
  end
end

Spork.each_run do
  require 'berkshelf'
end
