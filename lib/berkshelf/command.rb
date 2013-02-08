module Berkshelf
  # This superclass is responsible for handling common command methods and options.
  #
  # @author Seth Vargo <sethvargo@gmail.com>
  module Command
    private
      # Validate the options hash, ensuring there are no conflicting arguments
      #
      # @raise [Berkshelf::ArgumentError]
      #   if there are conflicting or invalid options
      def validate_options!(options)
        if options[:except] && options[:only]
          raise ArgumentError, "Cannot specify both :except and :only"
        end

        if options[:cookbooks] && (options[:except] || options[:only])
          Berkshelf.ui.warn ":cookbooks were supplied to update(), so :except and :only are ignored..."
        end
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
      def filter(sources, options = {})
        cookbooks = Array(options[:cookbooks]).map(&:to_s)
        except    = Array(options[:except]).map(&:to_sym)
        only      = Array(options[:only]).map(&:to_sym)

        case
        when !cookbooks.empty?
          missing_cookbooks = (cookbooks - sources.map(&:name))

          unless missing_cookbooks.empty?
            raise CookbookNotFound, "Could not find cookbooks #{missing_cookbooks.collect { |cookbook| "'#{cookbook}'"}.join(', ')} in any of the sources. #{missing_cookbooks.size == 1 ? 'Is it' : 'Are they' } in your Berksfile?"
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
