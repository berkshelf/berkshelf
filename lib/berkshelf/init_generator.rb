begin
  require 'kitchen/generator/init'
rescue LoadError; end

module Berkshelf
  class InitGenerator < BaseGenerator
    def initialize(*args)
      super(*args)
      if @options[:cookbook_name]
        @cookbook_name = @options[:cookbook_name]
      end
    end

    class_option :metadata_entry,
      type: :boolean,
      default: false

    class_option :chefignore,
      type: :boolean,
      default: false

    class_option :skip_vagrant,
      type: :boolean,
      default: false,
      desc: 'Skips adding a Vagrantfile and adding supporting gems to the Gemfile'

    class_option :skip_git,
      type: :boolean,
      default: false,
      desc: 'Skips adding a .gitignore and running git init in the cookbook directory'

    class_option :foodcritic,
      type: :boolean,
      default: false,
      desc: 'Creates a Thorfile with Foodcritic support to lint test your cookbook'

    class_option :chef_minitest,
      type: :boolean,
      default: false

    class_option :scmversion,
      type: :boolean,
      default: false,
      desc: 'Creates a Thorfile with SCMVersion support to manage versions for continuous integration'

    class_option :no_bundler,
      type: :boolean,
      default: false,
      desc: 'Skips generation of a Gemfile and other Bundler specific support'

    class_option :cookbook_name,
      type: :string

    if defined?(Kitchen::Generator::Init)
      class_option :skip_test_kitchen,
        type: :boolean,
        default: false,
        desc: 'Skip adding a testing environment to your cookbook'
    end

    def generate
      validate_configuration
      check_option_support

      template 'Berksfile.erb', target.join('Berksfile')
      template 'Thorfile.erb', target.join('Thorfile')

      if options[:chefignore]
        copy_file 'chefignore', target.join(Berkshelf::Chef::Cookbook::Chefignore::FILENAME)
      end

      unless options[:skip_git]
        template 'gitignore.erb', target.join('.gitignore')

        unless File.exists?(target.join('.git'))
          inside target do
            run 'git init', capture: true
          end
        end
      end

      if options[:chef_minitest]
        empty_directory target.join('files/default/tests/minitest/support')
        template 'default_test.rb.erb', target.join('files/default/tests/minitest/default_test.rb')
        template 'helpers.rb.erb', target.join('files/default/tests/minitest/support/helpers.rb')
      end

      if options[:scmversion]
        create_file target.join('VERSION'), '0.1.0'
      end

      unless options[:no_bundler]
        template 'Gemfile.erb', target.join('Gemfile')
      end

      if defined?(Kitchen::Generator::Init)
        unless options[:skip_test_kitchen]
          # Temporarily use Dir.chdir to ensure the destionation_root of test kitchen's generator
          # is where we expect until this bug can be addressed:
          # https://github.com/opscode/test-kitchen/pull/140
          Dir.chdir target do
            # Kitchen::Generator::Init.new([], {}, destination_root: target).invoke_all
            Kitchen::Generator::Init.new([], {}).invoke_all
          end
        end
      end

      unless options[:skip_vagrant]
        template 'Vagrantfile.erb', target.join('Vagrantfile')
      end
    end

    private

      def berkshelf_config
        Berkshelf::Config.instance
      end

      # Read the cookbook name from the metadata.rb
      #
      # @return [String]
      #   name of the cookbook
      def cookbook_name
        @cookbook_name ||= begin
          metadata = Ridley::Chef::Cookbook::Metadata.from_file(target.join('metadata.rb').to_s)
          metadata.name.empty? ? File.basename(target) : metadata.name
        rescue CookbookNotFound, IOError
          File.basename(target)
        end
      end

      # Assert valid configuration
      #
      # @raise [InvalidConfiguration] if the configuration is invalid
      #
      # @return [nil]
      def validate_configuration
        unless Config.instance.valid?
          raise InvalidConfiguration.new Config.instance.errors
        end
      end

      # Check for supporting gems for provided options
      #
      # @return [Boolean]
      def check_option_support
        assert_option_supported(:foodcritic) &&
        assert_option_supported(:scmversion, 'thor-scmversion') &&
        assert_default_supported(:no_bundler, 'bundler')
      end

      # Warn if the supporting gem for an option is not installed
      #
      # @return [Boolean]
      def assert_option_supported(option, gem_name = option.to_s)
        if options[option]
          begin
            Gem::Specification.find_by_name(gem_name)
          rescue Gem::LoadError
            Berkshelf.ui.warn "This cookbook was generated with --#{option}, however, #{gem_name} is not installed."
            Berkshelf.ui.warn "To make use of --#{option}: gem install #{gem_name}"
            return false
          end
        end
        true
      end

      # Warn if the supporting gem for a default is not installed
      #
      # @return [Boolean]
      def assert_default_supported(option, gem_name = option.to_s)
        unless options[option]
          begin
            Gem::Specification.find_by_name(gem_name)
          rescue Gem::LoadError
            Berkshelf.ui.warn "By default, this cookbook was generated to support #{gem_name}, however, #{gem_name} is not installed."
            Berkshelf.ui.warn "To skip support for #{gem_name}, use --#{option.to_s.gsub('_', '-')}"
            Berkshelf.ui.warn "To install #{gem_name}: gem install #{gem_name}"
            return false
          end
        end
        true
      end
  end
end
