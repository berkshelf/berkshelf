def windows?
  !!(RUBY_PLATFORM =~ /mswin|mingw|windows/)
end

require "aruba/cucumber"
require "aruba/in_process"
require "aruba/spawn_process"
require "cucumber/rspec/doubles"

Dir["spec/support/**/*.rb"].each { |f| require File.expand_path(f) }

World(Berkshelf::RSpec::PathHelpers)

# these tests used to start a chef-zero server on one port, and a berks-api server on another port
# they now start a chef-zero server that supports the universe endpoint on one port.
#
# if there becomes a need to integration test talking to a supermarket/universe endpoint and then
# talking to a separate chef-server, then these features could be split back up again, but the
# Berkshelf::RSpec::ChefServer helper class would need to support managing multiple chef-zero servers.
CHEF_SERVER_PORT = 26310
BERKS_API_PORT   = 26310

at_exit do
  Berkshelf::RSpec::ChefServer.stop
end

Before do

  # Legacy ENV variables until we can move over to all InProcess
  Berkshelf.instance_variable_set(:@berkshelf_path, nil)
  ENV["BERKSHELF_PATH"] = berkshelf_path.to_s
  ENV["BERKSHELF_CONFIG"] = Berkshelf.config.path.to_s
  ENV["BERKSHELF_CHEF_CONFIG"] = chef_config_path.to_s

  aruba.config.command_launcher = :in_process
  aruba.config.main_class = Berkshelf::Cli::Runner
  @dirs = ["spec/tmp/aruba"] # set aruba's temporary directory

  clean_tmp_path
  Berkshelf.initialize_filesystem
  Berkshelf::CookbookStore.instance.initialize_filesystem
  reload_configs
  Berkshelf::CachedCookbook.instance_variable_set(:@loaded_cookbooks, nil)

  # This appears to be dead code
  # endpoints = [
  #  {
  #    type: "chef_server",
  #    options: {
  #      url: "http://localhost:#{CHEF_SERVER_PORT}",
  #      client_name: "reset",
  #      client_key: File.expand_path("spec/config/berkshelf.pem"),
  #    },
  #  },
  # ]

  Berkshelf::RSpec::ChefServer.start(port: CHEF_SERVER_PORT)

  aruba.config.io_wait_timeout = Cucumber::JRUBY ? 7 : 5
  @aruba_timeout_seconds = Cucumber::JRUBY ? 35 : 15
end

Before("@spawn") do
  aruba.config.command_launcher = :spawn

  Berkshelf.instance_variable_set(:@berkshelf_path, nil)
  set_environment_variable("BERKSHELF_PATH", berkshelf_path.to_s)
  set_environment_variable("BERKSHELF_CONFIG", Berkshelf.config.path.to_s)
  set_environment_variable("BERKSHELF_CHEF_CONFIG", chef_config_path.to_s)
end

Before("@slow_process") do
  aruba.config.io_wait_timeout = Cucumber::JRUBY ? 70 : 30
  @aruba_timeout_seconds = Cucumber::JRUBY ? 140 : 60
end

require "berkshelf/cli"
