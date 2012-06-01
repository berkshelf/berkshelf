module KnifeCookbookDependencies
  class CookbookSource
    # @internal
    module Location
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def download(destination)
        raise NotImplementedError, "Function must be implemented on includer"
      end
    end

    # @internal
    class SiteLocation
      include Location

      attr_reader :api_uri
      attr_accessor :target_version

      OPSCODE_COMMUNITY_API = 'http://cookbooks.opscode.com/api/v1/cookbooks'.freeze

      class << self
        def unpack(target, destination)
          Archive::Tar::Minitar.unpack(Zlib::GzipReader.new(File.open(target, 'rb')), destination)
        end
      end

      def initialize(name, options = {})
        @name = name
        @target_version = options[:version_string] || "0.0.0"
        @api_uri = options[:site] || OPSCODE_COMMUNITY_API
      end

      def download(destination)
        uri = if target_version == "0.0.0"
          quietly { rest.get_rest(name)['latest_version'] }
        else
          uri_for_version(target_version)
        end

        remote_file = rest.get_rest(uri)['file']
        downloaded_tf = rest.get_rest(remote_file, true)

        self.class.unpack(downloaded_tf.path, destination.to_s)

        File.join(destination, name)
      rescue Net::HTTPServerException => e
        if e.response.code == "404"
          raise CookbookNotFound, "Cookbook '#{name}' not found at site: #{api_uri}"
        else
          raise
        end
      end

      def api_uri=(uri)
        @rest = nil
        @api_uri = uri
      end

      private

        def rest
          @rest ||= Chef::REST.new(api_uri, false, false)
        end

        def uri_for_version(version)
          "#{name}/versions/#{uri_escape_version(version)}"
        end

        def uri_escape_version(version)
          version.gsub('.', '_')
        end
    end

    # @internal
    class PathLocation
      include Location

      attr_accessor :path

      def initialize(name, options = {})
        @name = name
        @path = options[:path]
      end

      def download(destination)
        raise CookbookNotFound unless File.chef_cookbook?(path)
        
        path
      end
    end

    # @internal
    class GitLocation
      include Location

      attr_accessor :uri
      attr_accessor :branch

      def initialize(name, options)
        @name = name
        @uri = options[:git]
        @branch = options[:branch] || options[:ref] || options[:tag]
      end

      def download(destination)
        cb_path = File.join(destination, name)
        ::KCD::Git.clone(uri, cb_path)
        ::KCD::Git.checkout(cb_path, branch) if branch

        raise CookbookNotFound unless File.chef_cookbook?(cb_path)

        cb_path
      rescue KCD::GitError
        msg = "Cookbook '#{name}' not found at git: #{uri}" 
        msg << " with branch '#{branch}'" if branch
        raise CookbookNotFound, msg
      end

      private

        def git
          @git ||= KCD::Git.new(uri)
        end
    end

    attr_reader :name
    attr_reader :version_constraint
    attr_reader :groups
    attr_reader :location
    attr_reader :locked_version
    attr_reader :local_path

    # TODO: describe how the options on this function work.
    #
    # @param [String] name
    # @param [String] version_constraint (optional)
    # @param [Hash] options (optional)
    def initialize(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      name, constraint = args

      @name = name
      @version_constraint = DepSelector::VersionConstraint.new(constraint)
      @groups = []
      @local_path = nil

      raise ArgumentError if (options.keys & [:git, :path, :site]).length > 1

      options[:version_string] = version_constraint.version.to_s

      @location = case 
      when options[:git]
        GitLocation.new(name, options)
      when options[:path]
        PathLocation.new(name, options)
      when options[:site]
        SiteLocation.new(name, options)
      else
        SiteLocation.new(name, options)
      end

      @locked_version = DepSelector::Version.new(options[:locked_version]) if options[:locked_version]

      add_group(KnifeCookbookDependencies.shelf.active_group) if KnifeCookbookDependencies.shelf.active_group
      add_group(options[:group]) if options[:group]
      add_group(:default) if groups.empty?
      set_downloaded_status(false)
    end

    def add_group(*groups)
      groups = groups.first if groups.first.is_a?(Array)
      groups.each do |group|
        group = group.to_sym
        @groups << group unless @groups.include?(group)
      end
    end

    def download(destination)
      set_local_path location.download(destination)
    end

    def downloaded?
      !local_path.nil?
    end

    def metadata
      return nil unless local_path

      cookbook_metadata = Chef::Cookbook::Metadata.new
      cookbook_metadata.from_file(File.join(local_path, "metadata.rb"))
      cookbook_metadata
    end

    def to_s
      name
    end

    def has_group?(group)
      groups.select { |sg| sg == group }
    end

    private

      def set_downloaded_status(state)
        @downloaded_state = state
      end

      def set_local_path(path)
        @local_path = path
      end
  end
end
