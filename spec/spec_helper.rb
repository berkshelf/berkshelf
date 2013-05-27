# We set this variable to load additional test materials during cucumber
# runs, since aruba runs in a subprocess. See lib/berkshelf/test.rb
ENV['RUBY_ENV'] ||= 'test'

require 'rubygems'
require 'bundler'
require 'spork'

Spork.prefork do
  require 'pp'
  require 'rspec'
  require 'webmock/rspec'
  require 'vcr'

  APP_ROOT = File.expand_path('../../', __FILE__)
  ENV["BERKSHELF_PATH"] = File.join(APP_ROOT, "spec", "tmp", "berkshelf")
  ENV["BERKSHELF_CHEF_CONFIG"] = File.join(APP_ROOT, "spec", "config", "knife.rb")

  Dir[File.join(APP_ROOT, "spec/support/**/*.rb")].each {|f| require f}

  VCR.configure do |config|
    config.configure_rspec_metadata!
    config.cassette_library_dir = 'spec/fixtures/cassettes'
    config.hook_into :webmock
    config.default_cassette_options = { record: :new_episodes }
    config.ignore_localhost = true
  end

  RSpec.configure do |config|
    config.include Berkshelf::RSpec::FileSystemMatchers
    config.include Berkshelf::RSpec::ChefAPI
    config.include Berkshelf::RSpec::ChefServer

    # Disallow should syntax
    config.expect_with :rspec do |c|
      c.syntax = :expect
    end

    config.mock_with :rspec
    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.filter_run focus: true
    config.run_all_when_everything_filtered = true

    config.before(:suite) do
      Berkshelf::RSpec::ChefServer.start
      WebMock.disable_net_connect!(allow_localhost: true, net_http_connect_on_start: true)
    end

    config.after(:suite) do
      Berkshelf::RSpec::ChefServer.stop
    end

    config.before(:each) do
      Celluloid.shutdown
      Celluloid.boot
      clean_tmp_path
      Berkshelf.cookbook_store = Berkshelf::CookbookStore.new(tmp_path.join("downloader_tmp"))
      Berkshelf.set_format(:null)
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

  def git_origin_for(repo, options = {})
    "file://#{generate_fake_git_remote("git@github.com/RiotGames/#{repo}.git", options)}/.git"
  end

  def generate_fake_git_remote(uri, options = {})
    remote_bucket = Pathname.new(::File.dirname(__FILE__)).join('tmp', 'remote_repos')
    FileUtils.mkdir_p(remote_bucket)

    repo_name = uri.to_s.split('/').last.split('.')
    name = if repo_name.last == 'git'
      repo_name.first
    else
      repo_name.last
    end
    name = 'rspec_cookbook' if name.nil? or name.empty?

    path = ''
    capture(:stdout) do
      Dir.chdir(remote_bucket) do
        Berkshelf::Cli.new.invoke(:cookbook, [name], skip_vagrant: true, skip_test_kitchen: true, force: true)
      end

      Dir.chdir(path = remote_bucket.join(name)) do
      run! "git config receive.denyCurrentBranch ignore"
      run! "echo '# a change!' >> content_file"
      run! "git add ."
      run "git commit -am 'A commit.'"
        options[:tags].each do |tag|
          run! "echo '#{tag}' > content_file"
          run! "git add content_file"
          run "git commit -am '#{tag} content'"
          run "git tag '#{tag}' 2> /dev/null"
        end if options.has_key? :tags
        options[:branches].each do |branch|
          run! "git checkout -b #{branch} master 2> /dev/null"
          run! "echo '#{branch}' > content_file"
          run! "git add content_file"
          run "git commit -am '#{branch} content'"
          run "git checkout master 2> /dev/null"
        end if options.has_key? :branches
      end
    end
    path
  end

  def git_sha_for_ref(repo, ref)
    Dir.chdir local_git_origin_path_for(repo) do
      run!("git show-ref '#{ref}'").chomp.split(/\s/).first
    end
  end

  def local_git_origin_path_for(repo)
    remote_repos_path = tmp_path.join('remote_repos')
    FileUtils.mkdir_p(remote_repos_path)
    remote_repos_path.join(repo)
  end

  def clone_target
    tmp_path.join('clone_targets')
  end

  def clone_target_for(repo)
    clone_target.join(repo)
  end

  def run!(cmd)
    out = `#{cmd}`
    raise "#{cmd} did not succeed:\n\tstatus: #{$?.exitstatus}\n\toutput: #{out}" unless $?.success?
    out
  end

  def run(cmd)
    `#{cmd}`
  end
end

Spork.each_run do
  require 'berkshelf'

  module Berkshelf
    class GitLocation
      alias :real_clone :clone
      def clone
        fake_remote = generate_fake_git_remote(uri, tags: @branch ? [@branch] : [])
        tmp_clone = File.join(self.class.tmpdir, uri.gsub(/[\/:]/,'-'))
        @uri = "file://#{fake_remote}"
        real_clone
      end
    end
  end
end

