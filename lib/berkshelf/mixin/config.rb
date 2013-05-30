module Berkshelf
  module Mixin
    module Config
      def self.included(base)
        base.send(:extend, ClassMethods)
      end

      module ClassMethods
        # Load a Chef configuration from the given path.
        #
        # @raise [Berkshelf::ConfigNotFound]
        #   if the specified path does not exist on the system
        def from_file(filepath)
          self.new(filepath)
        rescue Errno::ENOENT => e
          raise Berkshelf::ConfigNotFound.new(self.class.name, filepath)
        end

        # Load the contents of the most probable Chef config. See {location}
        # for more information on how this logic is decided.
        def load
          self.new(location)
        end

        # Class method for defining a default option.
        #
        # @param [#to_sym] option
        #   the symbol to store as the key
        # @param [Object] value
        #   the return value
        def default_option(option, value)
          default_options[option.to_sym] = value
        end

        # A list of all the default options set by this class.
        #
        # @return [Hash]
        def default_options
          @default_options ||= {}
        end

        # The default location of the configuration file.
        #
        # @param [#to_s] path
        #   the path to the default location of the configuration file
        def default_location(path)
          @default_location = File.expand_path(path)
        end

        # @return [String, nil]
        attr_reader :default_location

        # Converts a path to a path usable for your current platform
        #
        # @param [String] path
        #
        # @return [String]
        def platform_specific_path(path)
          if RUBY_PLATFORM =~ /mswin|mingw|windows/
            system_drive = ENV['SYSTEMDRIVE'] ? ENV['SYSTEMDRIVE'] : ""
            path         = win_slashify File.join(system_drive, path.split('/')[2..-1])
          end

          path
        end

        private
          # @abstract
          #   include and override {location} in your class to define the
          #   default location logic
          def location
            default_location || raise(AbstractFunction, "You must implement #{self.class}#location to define default location logic!")
          end

          # Convert a unixy filepath to a windowsy filepath. Swaps forward slashes for
          # double backslashes
          #
          # @param [String] path
          #   filepath to convert
          #
          # @return [String]
          #   converted filepath
          def win_slashify(path)
            path.gsub(File::SEPARATOR, (File::ALT_SEPARATOR || '\\'))
          end
      end

      # The path to the file.
      #
      # @return [String, nil]
      attr_reader :path

      # Create a new configuration file from the given path.
      #
      # @param [#to_s, nil] filepath
      #   the filepath to read
      def initialize(filepath = nil)
        @path = filepath ? File.expand_path(filepath.to_s) : nil
        load
      end

      # Read and evaluate the contents of the filepath, if one was given at the
      # start.
      #
      # @return [Berkshelf::Mixin::Config]
      def load
        configuration # Need to call this to make sure it's populated
        self.instance_eval(IO.read(path), path, 1) if path && File.exists?(path)
        self
      end

      # Force a reload the contents of this file from disk.
      #
      # @return [Berkshelf::Mixin::Config]
      def reload!
        @configuration = nil
        load
        self
      end

      # Return the configuration value for the given key.
      #
      # @param [#to_sym] key
      #   they key to find a configuration value for
      def [](key)
        configuration[key.to_sym]
      end

      def method_missing(m, *args, &block)
        if args.length > 0
          configuration[m.to_sym] = (args.length == 1) ? args[0] : args
        else
          configuration[m.to_sym]
        end
      end

      # Save the contents of the file to the originally-supplied path.
      def save
        File.open(path, 'w+') { |f| f.write(to_rb + "\n") }
      end

      # Convert the file back to Ruby.
      #
      # @return [String]
      def to_rb
        configuration.map { |k,v| "#{k}(#{v.inspect})" }.join("\n")
      end

      private
        def configuration
          @configuration ||= self.class.default_options.dup
        end
    end
  end
end
