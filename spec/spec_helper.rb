require 'spork'

Spork.prefork do
  require 'rspec'
  require 'webmock/rspec'
  require 'vcr'

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
    config.include Berkshelf::RSpec::BerksAPIServer

    config.expect_with :rspec do |c|
      c.syntax = :expect
    end

    config.mock_with :rspec
    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.filter_run focus: true
    config.run_all_when_everything_filtered = true

    config.before(:suite) do
      WebMock.disable_net_connect!(allow_localhost: true, net_http_connect_on_start: true)
      Berkshelf::RSpec::ChefServer.start
      Berkshelf::RSpec::BerksAPIServer.start
      Berkshelf.set_format(:null)
      Berkshelf.ui.mute!
    end

    config.after(:suite) do
      Berkshelf.ui.unmute!
    end

    config.before(:all) do
      ENV['BERKSHELF_PATH'] = berkshelf_path.to_s
    end

    config.before(:each) do
      Berkshelf::RSpec::BerksAPIServer.clear_cache
      clean_tmp_path
      FileUtils.mkdir_p(ENV['BERKSHELF_PATH'])
      FileUtils.mkdir_p(Berkshelf::CookbookStore.instance.storage_path)
      reload_configs
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
