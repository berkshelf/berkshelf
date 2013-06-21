module Berkshelf
  module RSpec
    module PathHelpers
      def cookbook_store
        @_cookbook_store ||= Pathname.new(Berkshelf.cookbooks_dir).expand_path
      end

      def tmp_path
        @_tmp_path ||= app_root.join('tmp').expand_path
      end

      def berkshelf_path
        @_berkshelf_path ||= tmp_path.join('berkshelf').expand_path.to_s
      end

      def fixtures_path
        @_fixtures_path ||= app_root.join('spec/fixtures').expand_path
      end

      def chef_config_path
        @_chef_config_path ||= app_root.join('spec/config/knife.rb').expand_path.to_s
      end

      private
        def app_root
          @_app_root ||= Pathname.new(File.expand_path('../../..', __FILE__))
        end

        def purge_store_and_configs!
          FileUtils.rm_rf(cookbook_store)
          FileUtils.rm_rf(tmp_path)

          FileUtils.rm_rf(tmp_path)
          FileUtils.rm_rf(Berkshelf.berkshelf_path)

          FileUtils.mkdir(tmp_path)
          FileUtils.mkdir(Berkshelf.berkshelf_path)
          FileUtils.mkdir(Berkshelf.cookbooks_dir)

          Berkshelf.berkshelf_path = berkshelf_path
          Berkshelf.chef_config = Berkshelf::Chef::Config.from_file(chef_config_path)

          # This fucking sucks...
          load 'berkshelf/chef/config.rb'
          load 'berkshelf/config.rb'

          Berkshelf.config = Berkshelf::Config.new
        end
    end
  end
end
