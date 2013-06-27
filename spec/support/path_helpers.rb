module Berkshelf
  module RSpec
    module PathHelpers
      # The path to where berkshelf lives (tmp/berkshelf)
      #
      # @return [Pathname]
      def berkshelf_path
        @_berkshelf_path ||= tmp_path.join('berkshelf').expand_path
      end

      # The Berkshelf cookbook store
      #
      # @return [Berkshelf::CookbookStore]
      def cookbook_store
        Berkshelf.cookbook_store
      end

      # The tmp path where testing support/workspaces are
      #
      # @return [Pathname]
      def tmp_path
        @_tmp_path ||= app_root.join('tmp').expand_path
      end

      # The path to the spec fixtures
      #
      # @return [Pathname]
      def fixtures_path
        @_fixtures_path ||= app_root.join('spec/fixtures').expand_path
      end

      # The path to the Chef config fixture
      #
      # @return [String]
      def chef_config_path
        @_chef_config_path ||= app_root.join('spec/config/knife.rb').expand_path.to_s
      end

      # The actual Chef config object
      #
      # @return [Bershelf::Chef::Config]
      def chef_config
        @_chef_config ||= Berkshelf::Chef::Config.from_file(chef_config_path)
      end

      def clean_tmp_path
        FileUtils.rm_rf(tmp_path)
        FileUtils.mkdir_p(tmp_path)
      end

      private

        # The "root" of berkshelf
        #
        # @return [Pathname]
        def app_root
          @_app_root ||= Pathname.new(File.expand_path('../../..', __FILE__))
        end

        # This is the magical "reset" function that gives us a clean working
        # directory on each run.
        #
        # @return [nil]
        def purge_store_and_configs!
          FileUtils.rm_rf(tmp_path)
          FileUtils.mkdir(tmp_path)

          Berkshelf.berkshelf_path = berkshelf_path
          Berkshelf.chef_config    = chef_config

          FileUtils.mkdir(Berkshelf.berkshelf_path)
          FileUtils.mkdir(Berkshelf.cookbooks_dir)

          # This fucking sucks...
          load 'berkshelf/chef/config.rb'
          load 'berkshelf/config.rb'

          Berkshelf.config = Berkshelf::Config.new
          nil
        end
    end
  end
end
