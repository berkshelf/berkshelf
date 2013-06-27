require 'spork'

Spork.prefork do
  require 'aruba/cucumber'
  require 'aruba/in_process'
  require 'aruba/spawn_process'
  require 'cucumber/rspec/doubles'

  require 'berkshelf/cli'

  Dir['spec/support/**/*.rb'].each { |f| require File.expand_path(f) }

  World(Berkshelf::RSpec::PathHelpers)
  World(Berkshelf::RSpec::Kitchen)

  at_exit { Berkshelf::RSpec::ChefServer.stop }

  Before do
    Berkshelf::RSpec::ChefServer.start
    Aruba::InProcess.main_class = Berkshelf::Cli::Runner
    Aruba.process               = Aruba::InProcess

    stub_kitchen!
    purge_store_and_configs!
    Berkshelf::RSpec::ChefServer.reset!

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
end

Spork.each_run do
  require 'berkshelf/cli'
end
