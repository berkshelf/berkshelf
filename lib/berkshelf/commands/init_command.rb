module Berkshelf
  class Commands::InitCommand < CLI
    option ['-n', '--cookbook-name'], 'NAME', 'name of the cookbook'

    option '--[no-]bundler',      :flag, 'add Bundler support', default: true
    option '--[no-]chefignore',   :flag, 'create a chefignore file', default: true
    option '--[no-]chefspec',     :flag, 'add ChefSpec support', default: true
    option '--[no-]foodcritic',   :flag, 'add Foodcritic support', default: true
    option '--[no-]git',          :flag, 'add git support', default: true
    option '--[no-]minitest',     :flag, 'add MiniTest Chef Handler support', default: true
    option '--[no-]scmversion',   :flag, 'add Thor::SCMVersion support', default: false
    option '--[no-]test-kitchen', :flag, 'add Test Kitchen support', default: true
    option '--[no-]vagrant',      :flag, 'add Vagrant Berkshelf support', default: true

    parameter '[PATH]', 'directory where to create the cookbook', default: '.'

    def execute
      validate_cookbook!

      template 'Berksfile.erb', File.join(target, 'Berksfile')

      if bundler?
        verify_gem_installed('bundler')
        template 'Gemfile.erb', File.join(target, 'Gemfile')

        caveats << "Run `bundle install` to install any new gems."
      end

      if chefignore?
        template 'chefignore.erb', File.join(target, 'chefignore')
      end

      if chefspec?
        verify_gem_installed('chefspec') unless bundler?
        spec_dir = File.join(target, 'spec')

        directory File.join(spec_dir, 'recipes')
        template File.join('chefspec', 'spec_helper.erb'), File.join(spec_dir, 'spec_helper.rb')
        template File.join('chefspec', 'default_spec.erb'), File.join(spec_dir, 'recipes', 'default_spec.rb')
      end

      if foodcritic?
        verify_gem_installed('foodcritic') unless bundler?
      end

      if git?
        template 'gitignore.erb', File.join(target, '.gitignore')

        unless File.exists?(File.join(target, '.git'))
          Buff::ShellOut.shell_out("git init #{target}")
        end
      end

      if minitest?
        test_dir = File.join(target, 'files', 'default', 'tests', 'minitest')

        directory File.join(test_dir, 'support')
        template File.join('minitest', 'default_test.rb.erb'), File.join(test_dir, 'default_test.rb')
        template File.join('minitest', 'helpers.rb.erb'),      File.join(test_dir, 'support', 'helpers.rb')
      end

      if scmversion?
        verify_gem_installed('thor-scmversion') unless bundler?
        template 'VERSION.erb', File.join(target, 'VERSION')
      end

      if test_kitchen?
        verify_gem_installed('test-kitchen') unless bundler?

        begin
          require 'kitchen'
          require 'kitchen/generator/init'
          Kitchen::Generator::Init.new([], {}, destination_root: target).invoke_all
        rescue LoadError
          raise RuntimeError, "Test Kitchen not found! You must have the " \
            "test-kitchen installed on your system to initialize the " \
            "project with Test Kitchen support. Install test-kitchen by " \
            "running:" \
            "\n\n" \
            "  gem install test-kitchen" \
            "\n\n" \
            "or add Test Kitchen to your Gemfile:" \
            "\n\n" \
            "  gem 'test-kitchen'" \
            "\n\n"
        end
      end

      if vagrant?
        template 'Vagrantfile.erb', File.join(target, 'Vagrantfile')
      end

      # Warn of any caveats that happened during the run
      unless caveats.empty?
        Berkshelf.ui.alert_warning "\nCaveats:"

        caveats.each do |caveat|
          Berkshelf.ui.alert_warning("  " + caveat)
        end
      end

      Berkshelf.ui.say "Successfully initialized"
    end

    protected

      # Output the section with Ruby comments.
      #
      # @param [String] content
      #
      # @return [String]
      def commented(content)
        content.split("\n").collect { |s| "# #{s}" }.join("\n")
      end

      # Create a directory at the given path.
      #
      # @param [String] path
      def directory(path)
        FileUtils.mkdir_p(path)
      end

      # Render a template with the given name at the destination.
      #
      # @param [String] name
      # @param [String] destination
      def template(name, destination)
        result = render_file(generators.join(name))
        File.open(destination, 'w') { |f| f.write(result) }
      end

      # The path to the local generators.
      #
      # @return [Pathname]
      def generators
        Berkshelf.root.join('generator_files')
      end

      # The destination target.
      #
      # @return [String]
      def target
        File.expand_path(path)
      end

      # Render the file and parse as ERB, returning the result as a String.
      #
      # @param [String] path
      #
      # @return [String]
      def render_file(path)
        ERB.new(File.read(path), nil, '-').result(binding)
      end

      # Assert the current working directory is a cookbook.
      #
      # @raise [NotACookbook] if the current working directory is not a cookbook
      #
      # @return [nil]
      def validate_cookbook!
        path = File.expand_path(File.join(target, 'metadata.rb'))
        unless File.exists?(path)
          raise Berkshelf::NotACookbook.new(path)
        end
      end

      # Verify that the gem is installed, appending any caveats as appropiate.
      def verify_gem_installed(gem_name)
        Gem::Specification.find_by_name(gem_name)
      rescue Gem::LoadError
        caveats << "To make use of #{gem_name}, run `gem install #{gem_name}`"
      end

      # Shortcut proxy method for accessing the Berkshelf config (used by
      # templates and is passed in as part of the binding).
      #
      # @return [Berkshelf::Config]
      def berkshelf_config
        Berkshelf.config
      end

      # List of caveats to tell the user at the end.
      #
      # @return [Array]
      def caveats
        @caveats ||= []
      end

      # Compute the name of the cookbook (using the option if provided).
      #
      # This method will attempt to read the +metadata.rb+, falling back to
      # the directory name if it cannot be parsed or does not exist.
      #
      # @return [String]
      def cookbook_name
        @cookbook_name ||= begin
          path = File.expand_path(File.join(target, 'metadata.rb'))
          MetadataExtractor.new(path)[:name]
        rescue IOError; end || File.basename(target)
      end

      class MetadataExtractor < Hash
        def initialize(path)
          eval(IO.read(path), nil, path)
        end

        def method_missing(m, *args, &block)
          self[m] = args.first
        end
      end
  end
end
