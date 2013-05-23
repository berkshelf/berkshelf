# require 'spork'

# Spork.prefork do
  # These must be set BEFORE any require 'berkshelf' calls are made!
  ENV['RUBY_ENV']              = 'test'
  ENV['BERKSHELF_PATH']        = File.expand_path(File.join('tmp', 'berkshelf'))
  ENV['BERKSHELF_CHEF_CONFIG'] = File.expand_path(File.join('spec', 'config', 'knife.rb'))

  require 'aruba/cucumber'
  require 'aruba/in_process'
  require 'aruba/spawn_process'

  module Aruba
    class InProcess
      def stdin
        @stdin
      end

      def output
        stdout + stderr
      end
    end
  end

  require 'berkshelf'
  require 'berkshelf/cli'

  Dir['spec/support/**/*.rb'].each { |f| require File.expand_path(f) }

  Before do
    Aruba::InProcess.main_class = Berkshelf::Main
    Aruba.process = Aruba::InProcess

    purge_store_and_configs!

    @aruba_io_wait_seconds = 5
    @aruba_timeout_seconds = 16
  end

  Before('@spawn') do
    Aruba.process = Aruba::SpawnProcess
  end

  Before('@slow_process') do
    @aruba_timeout_seconds = 60
    @aruba_io_wait_seconds = 30
  end

  # Chef Zero
  require 'chef_zero/server'
  @server = ChefZero::Server.new(port: 4000)
  @server.start_background

  at_exit do
    @server.stop if @server && @server.running?
  end

  def purge_store_and_configs!
    # Berkshelf::Chef::Config.reload
    # Berkshelf::Config.reload

    FileUtils.rm_rf(Berkshelf.berkshelf_path)
    FileUtils.mkdir_p(Berkshelf.cookbooks_dir)
  end

  def cookbook_store
    Pathname.new(Berkshelf.cookbooks_dir)
  end

  def tmp_path
    File.expand_path(File.join('tmp'))
  end

  def fixtures_path
    File.expand_path(File.join('spec', 'fixtures'))
  end
# end

# Spork.each_run do
#   require 'berkshelf'
# end
