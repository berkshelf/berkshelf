module Berkshelf
  # This superclass is responsible for handling common command methods and options.
  #
  # @author Seth Vargo <sethvargo@gmail.com>
  module Command
    # Initialize a new instance of the parent class
    # @param [Hash] options
    #   the list of options to pass to the installer
    def initialize(options = {})
      @options = options
    end

    private

      # Validate the options hash, ensuring there are no conflicting arguments
      #
      # @raise [Berkshelf::ArgumentError]
      #   if there are conflicting or invalid options
      def validate_options!
        if options[:except] && options[:only]
          raise ::Berkshelf::ArgumentError, "Cannot specify both :except and :only"
        end

        if options[:cookbooks] && (options[:except] || options[:only])
          ::Berkshelf.ui.warn ":cookbooks were supplied to update(), so :except and :only are ignored..."
        end
      end

      # Ensure the berkshelf directory is created and accessible.
      def ensure_berkshelf_directory!
        unless ::File.exists?(Berkshelf.berkshelf_path)
          ::FileUtils.mkdir_p(Berkshelf.berkshelf_path)
        end
      end

      # Check for the presence of a Berksfile. Berkshelf cannot do anything
      # without the presence of a Berksfile.lock.
      def ensure_berksfile!
        unless ::File.exists?(options[:berksfile])
          raise ::Berkshelf::BerksfileNotFound, "No #{options[:berksfile]} was found at ."
        end
      end

      # Check that the Berksfile has content. If the Berksfile is empty, raise
      # an exception to require at least one definition.
      def ensure_berksfile_content!
        begin
          unless ::File.read(options[:berksfile]).size > 1
            raise ::Berksfile::BerksfileNotFound, "Your #{options[:berksfile]} is empty! You need at least one cookbook definition."
          end
        rescue Errno::ENOENT
          ensure_berksfile!
        end
      end

      # @return [Hash]
      #   the options for this installer
      def options
        @options ||= {}
      end

      # Attempt to load and parse the lockfile associated with this berksfile.
      #
      # @return [Berkshelf::Lockfile, nil]
      #   the lockfile for the current berksfile
      def lockfile
        @lockfile ||= berksfile.lockfile
      end

      # Load the Berksfile for the current project.
      #
      # @raise [Berkshelf::BerksfileNotFound]
      #   if the file is not found
      #
      # @return [Berkshelf::Berksfile]
      #   the current Berksfile
      def berksfile
        @berksfile ||= ::Berkshelf::Berksfile.from_file(options[:berksfile])
      end

      # Filter the list of sources from the options passed to the installer.
      #
      # @param [Array<Berkshelf::CookbookSource>] sources
      #   the list of sources to resolve
      #
      # @raise [Berkshelf::ArgumentError]
      #   if a value for both :except and :only is provided
      #
      # @raise [Berkshelf::CookbookNotFound]
      #   if a cookbook name is specified that does not exist
      #
      # @return [Array<Berkshelf::CookbookSource>]
      def filter(sources)
        cookbooks = Array(options[:cookbooks]).map(&:to_s)
        except    = Array(options[:except]).map(&:to_sym)
        only      = Array(options[:only]).map(&:to_sym)

        case
        when !cookbooks.empty?
          missing_cookbooks = (cookbooks - sources.map(&:name))

          unless missing_cookbooks.empty?
            raise ::Berkshelf::CookbookNotFound, "Could not find cookbooks #{missing_cookbooks.collect{|cookbook| "'#{cookbook}'"}.join(', ')} in any of the sources. #{missing_cookbooks.size == 1 ? 'Is it' : 'Are they' } in your Berksfile?"
          end

          sources.select { |source| options[:cookbooks].include?(source.name) }
        when !except.empty?
          sources.select { |source| (except & source.groups).empty? }
        when !only.empty?
          sources.select { |source| !(only & source.groups).empty? }
        else
          sources
        end
      end

  end
end
