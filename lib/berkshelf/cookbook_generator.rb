module Berkshelf
  class CookbookGenerator < BaseGenerator
    require_relative 'config'

    LICENSE_MAP = {
      "apachev2" => "Apache 2.0",
      "gplv2"    => "GNU Public License 2.0",
      "gplv3"    => "GNU Public License 3.0",
      "mit"      => "MIT",
      "reserved" => "All rights reserved",
    }.freeze

    (LICENSES = LICENSE_MAP.keys).freeze

    argument :name,
      type: :string,
      required: true

    class_option :skip_vagrant,
      type: :boolean,
      default: false

    class_option :skip_git,
      type: :boolean,
      default: false

    class_option :skip_test_kitchen,
      type: :boolean,
      default: false,
      desc: 'Skip adding a testing environment to your cookbook'

    class_option :foodcritic,
      type: :boolean,
      default: false

    class_option :chef_minitest,
      type: :boolean,
      default: false

    class_option :scmversion,
      type: :boolean,
      default: false

    class_option :no_bundler,
      type: :boolean,
      default: false

    class_option :license,
      type: :string,
      default: Berkshelf.config.cookbook.license

    class_option :maintainer,
      type: :string,
      default: Berkshelf.config.cookbook.copyright

    class_option :maintainer_email,
      type: :string,
      default: Berkshelf.config.cookbook.email

    def generate
      case options[:pattern]
      when "library"
        empty_directory target.join("libraries")
        empty_directory target.join("providers")
        empty_directory target.join("resources")
      when "wrapper"
        empty_directory target.join("attributes")
        empty_directory target.join("recipes")
        template "default_recipe.erb", target.join("recipes/default.rb")
      when "environment", "application"
        empty_directory target.join("files/default")
        empty_directory target.join("templates/default")
        empty_directory target.join("attributes")
        empty_directory target.join("libraries")
        empty_directory target.join("providers")
        empty_directory target.join("recipes")
        empty_directory target.join("resources")
        template "default_recipe.erb", target.join("recipes/default.rb")
      end

      template 'metadata.rb.erb', target.join('metadata.rb')
      template license_file, target.join('LICENSE')
      template 'README.md.erb', target.join('README.md')
      template 'CHANGELOG.md.erb', target.join('CHANGELOG.md')

      Berkshelf::InitGenerator.new([target], options.merge(default_options)).invoke_all
    end

    private

      def commented(content)
        content.split("\n").collect { |s| s == "" ? "#" : "# #{s}"}.join("\n")
      end

      def license_name
        LICENSE_MAP.fetch(options[:license]) do |license|
          raise Berkshelf::LicenseNotFound.new(license)
        end
      end

      def license
        ERB.new(File.read(File.join(self.class.source_root, license_file))).result(binding)
      end

      def license_file
        case options[:license]
        when 'apachev2'; 'licenses/apachev2.erb'
        when 'gplv2'; 'licenses/gplv2.erb'
        when 'gplv3'; 'licenses/gplv3.erb'
        when 'mit'; 'licenses/mit.erb'
        when 'reserved'; 'licenses/reserved.erb'
        else
          raise Berkshelf::LicenseNotFound.new(options[:license])
        end
      end

      def copyright_year
        Time.now.year
      end

      def maintainer
        options[:maintainer]
      end

      def maintainer_email
        options[:maintainer_email]
      end

      def default_options
        { metadata_entry: true, chefignore: true, cookbook_name: name }
      end
  end
end
