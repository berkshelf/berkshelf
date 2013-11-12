require 'berkshelf/config'
require 'berkshelf/commands/init_command'

module Berkshelf
  class CookbookCommand < InitCommand
    LICENSES = [
      'apachev2',
      'gplv2',
      'gplv3',
      'mit',
      'reserved'
    ].freeze

    option ['-l', '--license'],          'TYPE', 'license to use', default: Berkshelf.config.cookbook.license, attribute_name: 'license_type'
    option ['-m', '--maintainer'],       'NAME', 'name of the maintainer', default: Berkshelf.config.cookbook.copyright
    option ['-e', '--maintainer-email'], 'EMAIL', 'email for the maintainer', default: Berkshelf.config.cookbook.email

    parameter 'NAME', 'cookbook name'

    def execute
      directory File.join(target, 'attributes')
      directory File.join(target, 'files', 'default')
      directory File.join(target, 'libraries')
      directory File.join(target, 'providers')
      directory File.join(target, 'recipes')
      directory File.join(target, 'resources')
      directory File.join(target, 'templates', 'default')

      template 'default_recipe.erb', File.join(target, 'recipes', 'default.rb')
      template 'metadata.rb.erb',    File.join(target, 'metadata.rb')
      template license_file,         File.join(target, 'LICENSE')
      template 'README.md.erb',      File.join(target, 'README.md')

      @cookbook_name = name
      super
    end

    protected

      def target
        @target = File.expand_path(name, path)
      end

    private

      def license_name
        case license_type
        when 'apachev2'; 'Apache 2.0'
        when 'gplv2'; 'GNU Public License 2.0'
        when 'gplv3'; 'GNU Public License 3.0'
        when 'mit'; 'MIT'
        when 'reserved'; 'All rights reserved'
        else
          raise Berkshelf::LicenseNotFound.new(license_type)
        end
      end

      def license
        render_file(generators.join(license_file))
      end

      def license_file
        case license_type
        when 'apachev2'; 'licenses/apachev2.erb'
        when 'gplv2'; 'licenses/gplv2.erb'
        when 'gplv3'; 'licenses/gplv3.erb'
        when 'mit'; 'licenses/mit.erb'
        when 'reserved'; 'licenses/reserved.erb'
        else
          raise Berkshelf::LicenseNotFound.new(license_type)
        end
      end

      def copyright_year
        Time.now.year
      end

  end
end
