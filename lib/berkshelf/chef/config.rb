require 'socket'

module Berkshelf::Chef
  class Config
    class << self
      # Load a Chef configuration from the given path.
      #
      # @raise [Berkshelf::ChefConfigNotFound]
      #   if the specified path does not exist on the system
      def from_file(filepath)
        self.new(filepath)
      rescue Errno::ENOENT => e
        raise Berkshelf::ChefConfigNotFound.new(filepath)
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

      private
        # Return the most sensible path to the Chef configuration file. This can
        # be configured by setting a value for the 'BERKSHELF_CHEF_CONFIG' environment
        # variable.
        #
        # @return [String, nil]
        def location
          possibles = []

          possibles << ENV['BERKSHELF_CHEF_CONFIG'] if ENV['BERKSHELF_CHEF_CONFIG']
          possibles << File.join(ENV['KNIFE_HOME'], 'knife.rb') if ENV['KNIFE_HOME']
          possibles << File.join(working_dir, 'knife.rb') if working_dir

          # Ascending search for .chef directory siblings
          Pathname.new(working_dir).ascend do |file|
            sibling_chef = File.join(file, '.chef')
            possibles << File.join(sibling_chef, 'knife.rb')
          end if working_dir

          possibles << File.join(ENV['HOME'], '.chef', 'knife.rb') if ENV['HOME']
          possibles.compact!

          location = possibles.find { |loc| File.exists?(File.expand_path(loc)) }

          File.expand_path(location) unless location.nil?
        end

        # The current working directory
        #
        # @return [String]
        def working_dir
          ENV['PWD'] || Dir.pwd
        end
    end

    default_option(:node_name,                Socket.gethostname)
    default_option(:chef_server_url,          'http://localhost:4000')
    default_option(:client_key,               Berkshelf::Util.platform_specific_path('/etc/chef/client.pem'))
    default_option(:validation_key,           Berkshelf::Util.platform_specific_path('/etc/chef/validation.pem'))
    default_option(:validation_client_name,   'chef-validator')

    default_option(:cookbook_copyright,       'YOUR_NAME')
    default_option(:cookbook_email,           'YOUR_EMAIL')
    default_option(:cookbook_license,         'reserved')

    default_option(:knife, {})

    # Prior to Chef 11, the cache implementation was based on
    # moneta and configured via cache_options[:path]. Knife configs
    # generated with Chef 11 will have `syntax_check_cache_path`, but older
    # configs will have `cache_options[:path]`. `cache_options` is marked
    # deprecated in chef/config.rb but doesn't currently trigger a warning.
    # See also: CHEF-3715
    default_option(:syntax_check_cache_path,  Dir.mktmpdir)
    default_option(:cache_options,            { path: defined?(syntax_check_cache_path) ? syntax_check_cache_path : Dir.mktmpdir })

    attr_reader :path

    # Create a new Chef configuration file from the given path.
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
    # @return [Berkshelf::Chef::Config]
    def load
      self.instance_eval(IO.read(path), path, 1) if path && File.exists?(path)
      self
    end

    # Force a reload the contents of this file from disk.
    #
    # @return [Berkshelf::Chef::Config]
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

    private
      def configuration
        @configuration ||= self.class.default_options.dup
      end
  end
end
