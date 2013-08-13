module Berkshelf
  module RSpec
    module PathHelpers
      # The path to where berkshelf lives (tmp/berkshelf)
      #
      # @return [Pathname]
      def berkshelf_path
        tmp_path.join('berkshelf').expand_path
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
        Berkshelf.root.join('spec/tmp')
      end

      # The path to the spec fixtures
      #
      # @return [Pathname]
      def fixtures_path
        Berkshelf.root.join('spec/fixtures')
      end

      # The path to the Chef config fixture
      #
      # @return [String]
      def chef_config_path
        Berkshelf.root.join('spec/config/knife.rb').to_s
      end

      # The actual Chef config object
      #
      # @return [Bershelf::Chef::Config]
      def chef_config
        Ridley::Chef::Config.from_file(chef_config_path)
      end

      def clean_tmp_path
        FileUtils.rm_rf(tmp_path)
        FileUtils.mkdir_p(tmp_path)
      end

      private

        # This is the magical "reset" function that gives us a clean working
        # directory on each run.
        #
        # @return [nil]
        def reload_configs
          Berkshelf.chef_config = chef_config

          # This fucking sucks...
          # load 'berkshelf/chef/config.rb'
          load 'berkshelf/config.rb'

          Berkshelf.config = Berkshelf::Config.new
          nil
        end
    end
  end
end
