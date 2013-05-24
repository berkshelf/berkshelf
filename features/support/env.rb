require 'spork'

Spork.prefork do
  # This must be set BEFORE any require 'berkshelf' calls are made!
  ENV['RUBY_ENV']              = 'test'

  require 'aruba/cucumber'
  require 'aruba/in_process'
  require 'aruba/spawn_process'

  require 'berkshelf'
  require 'berkshelf/cli'

  Dir['spec/support/**/*.rb'].each { |f| require File.expand_path(f) }

  Before do
    Aruba::InProcess.main_class = Berkshelf::Main
    Aruba.process = Aruba::InProcess

    purge_store_and_configs!

    @aruba_io_wait_seconds = Cucumber::JRUBY ? 10 :15
    @aruba_timeout_seconds = Cucumber::JRUBY ? 35 : 15
  end

  Before('@spawn') do
    Aruba.process = Aruba::SpawnProcess

    # Legacy ENV variables until we can move over to all in-process
    set_env('BERKSHELF_PATH', berkshelf_path)
    set_env('BERKSHELF_CHEF_CONFIG', chef_config_path)
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

  def purge_store_and_configs!
    FileUtils.rm_rf(tmp_path)
    FileUtils.rm_rf(Berkshelf.berkshelf_path)

    Berkshelf.berkshelf_path = berkshelf_path
    Berkshelf.chef_config = Berkshelf::Chef::Config.from_file(chef_config_path)

    FileUtils.mkdir_p(Berkshelf.cookbooks_dir)
    load 'berkshelf/config.rb'
  end

  def cookbook_store
    Pathname.new(Berkshelf.cookbooks_dir)
  end

  def tmp_path
    File.expand_path(File.join('tmp'))
  end

  def berkshelf_path
    File.expand_path(File.join(tmp_path, 'berkshelf'))
  end

  def fixtures_path
    File.expand_path(File.join('spec', 'fixtures'))
  end

  def chef_config_path
    File.expand_path(File.join('spec', 'config', 'knife.rb'))
  end
end

Spork.each_run do
  require 'berkshelf'
end
