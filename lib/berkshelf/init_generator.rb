module Berkshelf
  # @author Jamie Winsor <jamie@vialstudios.com>
  class InitGenerator < BaseGenerator
    def initialize(*args)
      super(*args)
      if @options[:cookbook_name]
        @cookbook_name = @options[:cookbook_name]
      end
    end

    argument :path,
      type: :string,
      required: true

    class_option :metadata_entry,
      type: :boolean,
      default: false

    class_option :chefignore,
      type: :boolean,
      default: false

    class_option :skip_vagrant,
      type: :boolean,
      default: false

    class_option :skip_git,
      type: :boolean,
      default: false

    class_option :foodcritic,
      type: :boolean,
      default: false

    class_option :scmversion,
      type: :boolean,
      default: false

    class_option :no_bundler,
      type: :boolean,
      default: false

    class_option :cookbook_name,
      type: :string

    class_option :berkshelf_config,
      type: :hash,
      default: Config.instance

    def generate
      validate_configuration
      validate_options

      template "Berksfile.erb", target.join("Berksfile")

      if options[:chefignore]
        copy_file "chefignore", target.join("chefignore")
      end

      unless options[:skip_git]
        template "gitignore.erb", target.join(".gitignore")

        unless File.exists?(target.join(".git"))
          inside target do
            run "git init", capture: true
          end
        end
      end

      if options[:foodcritic] || options[:scmversion]
        template "Thorfile.erb", target.join("Thorfile")
      end

      if options[:scmversion]
        create_file target.join("VERSION"), "0.1.0"
      end

      unless options[:no_bundler]
        template "Gemfile.erb", target.join("Gemfile")
      end

      unless options[:skip_vagrant]
        template "Vagrantfile.erb", target.join("Vagrantfile")
        ::Berkshelf::Cli.new([], berksfile: target.join("Berksfile")).invoke(:install)
      end
    end

    private

      def cookbook_name
        @cookbook_name ||= begin
          metadata = Chef::Cookbook::Metadata.new

          metadata.from_file(target.join("metadata.rb").to_s)
          metadata.name.empty? ? File.basename(target) : metadata.name
        rescue IOError
          File.basename(target)
        end
      end
  
      def validate_configuration
        unless Config.instance.valid?
          raise InvalidConfiguration.new Config.instance.errors
        end
      end
      
      def validate_options
        assert_option_supported(:foodcritic)
        assert_option_supported(:scmversion, 'thor-scmversion')
        assert_default_supported(:no_bundler, 'bundler')
        # Vagrant is a dependency of Berkshelf, so it will always appear available to the Berkshelf process.
      end
  
      def assert_option_supported(option, gem_name = option.to_s, affirmative = true)
        if options[option]
          begin
            Gem::Specification.find_by_name(gem_name)
          rescue Gem::LoadError
            Berkshelf.ui.warn "This cookbook was generated with --#{option}, however, #{gem_name} is not installed."
            Berkshelf.ui.warn "To make use of --#{option}: gem install #{gem_name}"
          end
        end
      end
  
      def assert_default_supported(option, gem_name = option.to_s)
        unless options[option]
          begin
            Gem::Specification.find_by_name(gem_name)
          rescue Gem::LoadError
            Berkshelf.ui.warn "By default, this cookbook was generated to support #{gem_name}, however, #{gem_name} is not installed."
            Berkshelf.ui.warn "To skip support for #{gem_name}, use --#{option}"
            Berkshelf.ui.warn "To install #{gem_name}: gem install #{gem_name}"
          end
        end
      end
  end
end
