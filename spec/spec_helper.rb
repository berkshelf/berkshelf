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

  Dir['spec/support/**/*.rb'].each { |f| require File.expand_path(f) }

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
    config.include Berkshelf::RSpec::Git
    config.include Berkshelf::RSpec::PathHelpers

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

      purge_store_and_configs!

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
end

Spork.each_run do
  require 'berkshelf'

  module Berkshelf
    class GitLocation
      include Berkshelf::RSpec::Git

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

