require 'rubygems'
require 'bundler'
require 'spork'

Spork.prefork do
  require 'rspec'
  require 'pp'
  require 'aruba/cucumber'
  require 'chef_zero/server'

  APP_ROOT = File.expand_path('../../../', __FILE__)

  ENV['RUBY_ENV'] = 'test'
  ENV['BERKSHELF_PATH'] = File.join(APP_ROOT, 'tmp', 'berkshelf')
  ENV['BERKSHELF_CHEF_CONFIG'] = File.join(APP_ROOT, 'spec', 'knife.rb')

  # Workaround for RSA Fingerprint prompt in Travis CI
  git_ssh_path = '/tmp/git_ssh.sh'
  unless File.exist? git_ssh_path
    git_ssh = File.new(git_ssh_path, 'w+')
    git_ssh.puts 'ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $1 $2'
    git_ssh.chmod 0775
    git_ssh.flush
    git_ssh.close
  end

  ENV['GIT_SSH'] = git_ssh_path

  Dir[File.join(APP_ROOT, 'spec/support/**/*.rb')].each {|f| require f}

  World(Berkshelf::TestGenerators)

  Before do
    set_env 'RUBY_ENV', 'test'
    clean_cookbook_store
    generate_berks_config(File.join(ENV['BERKSHELF_PATH'], 'config.json'))
    @aruba_io_wait_seconds = 5
    @aruba_timeout_seconds = 16
  end

  Before('@slow_process') do
    @aruba_timeout_seconds = 60
    @aruba_io_wait_seconds = 30
  end

  # Chef Zero
  @server = ChefZero::Server.new(port: 4000)
  @server.start_background

  at_exit do
    @server.stop if @server
  end

  def cookbook_store
    Pathname.new(File.join(ENV['BERKSHELF_PATH'], 'cookbooks'))
  end

  def clean_cookbook_store
    FileUtils.rm_rf(cookbook_store)
    FileUtils.mkdir_p(cookbook_store)
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
end

Spork.each_run do
  Berkshelf::RSpec::Knife.load_knife_config(File.join(APP_ROOT, 'spec/knife.rb'))

  require 'berkshelf'
end
