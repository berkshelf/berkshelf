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
      attr_accessor :version_constraint

      OPSCODE_COMMUNITY_API = 'http://cookbooks.opscode.com/api/v1/cookbooks'.freeze

      class << self
        # @param [String] target
        #   file path to the tar.gz archive on disk
        # @param [String] destination
        #   file path to extract the contents of the target to
        def unpack(target, destination)
          Archive::Tar::Minitar.unpack(Zlib::GzipReader.new(File.open(target, 'rb')), destination)
        end

        # @param [DepSelector::VersionConstraint] constraint
        #   version constraint to solve for
        #
        # @param [Hash] versions
        #   a hash where the keys are a DepSelector::Version representing a Cookbook version
        #   number and their values are the URI the Cookbook of the corrosponding version can
        #   be downloaded from. This format is also the output of the #versions function on 
        #   instances of this class.
        #
        #   Example:
        #       { 
        #         0.101.2 => "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_101_2",
        #         0.101.0 => "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_101_0",
        #         0.100.2 => "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_100_2",
        #         0.100.0 => "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_100_0"
        #       }
        #
        # @return [Array]
        #   an array where the first element is a DepSelector::Version representing the best version
        #   for the given constraint and the second element is the URI to where the corrosponding
        #   version of the Cookbook can be downloaded from
        #
        #   Example:
        #       [ 0.101.2 => "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_101_2" ]
        def solve_for_constraint(constraint, versions)
          versions.each do |version, uri|
            if constraint.include?(version)
              return [ version, uri ]
            end
          end

          raise "NO FUCKING SOLUTION"
        end
      end

      def initialize(name, options = {})
        options[:site] ||= OPSCODE_COMMUNITY_API

        @name = name
        @version_constraint = options[:version_constraint]
        @api_uri = options[:site]
      end

      def download(destination)
        version, uri = target_version
        remote_file = rest.get_rest(uri)['file']
        downloaded_tf = rest.get_rest(remote_file, true)

        dir = Dir.mktmpdir
        cb_path = File.join(destination, "#{name}-#{version}")

        self.class.unpack(downloaded_tf.path, dir)
        FileUtils.mv(File.join(dir, name), cb_path, :force => true)

        cb_path
      end

      def downloaded?(destination)
        version, uri = target_version
        cb_path = File.join(destination, "#{name}-#{version}")

        if File.exists?(cb_path) && File.chef_cookbook?(cb_path)
          cb_path
        else
          nil
        end
      end

      # @return [Array]
      #   an Array where the first element is a DepSelector::Version representing the latest version of
      #   the Cookbook and the second element is the URI to where the corrosponding version of the
      #   Cookbook can be downloaded from
      #
      #   Example:
      #       [ 0.101.2, "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_101_2" ]
      def version(version_string)
        quietly {
          result = rest.get_rest("#{name}/versions/#{uri_escape_version(version_string)}")
          dep_ver = DepSelector::Version.new(result['version'])

          [ dep_ver, result['file'] ]
        }
      rescue Net::HTTPServerException => e
        if e.response.code == "404"
          raise CookbookNotFound, "Cookbook name: '#{name}' version: '#{version_string}' not found at site: '#{api_uri}'"
        else
          raise
        end
      end

      # @return [Hash]
      #   a hash where the keys are a DepSelector::Version representing a Cookbook version
      #   number and their values are the URI the Cookbook of the corrosponding version can
      #   be downloaded from
      #
      #   Example:
      #       { 
      #         0.101.2 => "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_101_2",
      #         0.101.0 => "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_101_0",
      #         0.100.2 => "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_100_2",
      #         0.100.0 => "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_100_0"
      #       }
      def versions
        versions = Hash.new
        quietly {
          rest.get_rest(name)['versions'].each do |uri|
            version_string = version_from_uri(File.basename(uri))
            version = DepSelector::Version.new(version_string)

            versions[version] = uri
          end
        }

        versions
      rescue Net::HTTPServerException => e
        if e.response.code == "404"
          raise CookbookNotFound, "Cookbook '#{name}' not found at site: '#{api_uri}'"
        else
          raise
        end
      end

      # @return [Array]
      #   an array where the first element is a DepSelector::Version representing the latest version of
      #   the Cookbook and the second element is the URI to where the corrosponding version of the
      #   Cookbook can be downloaded from
      #
      #   Example:
      #       [ 0.101.2 => "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_101_2" ]
      def latest_version
        quietly {
          uri = rest.get_rest(name)['latest_version']
          version_string = version_from_uri(uri)
          dep_ver = DepSelector::Version.new(version_string)

          [ dep_ver, uri ]
        }
      rescue Net::HTTPServerException => e
        if e.response.code == "404"
          raise CookbookNotFound, "Cookbook '#{name}' not found at site: '#{api_uri}'"
        else
          raise
        end
      end

      def api_uri=(uri)
        @rest = nil
        @api_uri = uri
      end

      def to_s
        "site: '#{api_uri}'"
      end

      private

        def rest
          @rest ||= Chef::REST.new(api_uri, false, false)
        end

        def uri_escape_version(version)
          version.gsub('.', '_')
        end

        def version_from_uri(latest_version)
          File.basename(latest_version).gsub('_', '.')
        end

        # @return [Array]
        #   an Array where the first element is a DepSelector::Version and the second element is
        #   the URI to where the corrosponding version of the Cookbook can be downloaded from.
        #
        #
        #   The version is determined by the value of the version_constraint attribute of this
        #   instance of SiteLocation:
        #
        #   If it is not set: the latest_version of the Cookbook will be returned
        #
        #   If it is set: the return value will be determined by the version_constraint and the 
        #     available versions will be solved
        #
        #   Example:
        #       [ 0.101.2, "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_101_2" ]
        def target_version
          if version_constraint
            self.class.solve_for_constraint(version_constraint, versions)
          else
            latest_version
          end
        end
    end

    # @internal
    class PathLocation
      include Location

      attr_accessor :path

      def initialize(name, options = {})
        @name = name
        @path = File.expand_path(options[:path])
      end

      def download(destination)
        unless File.chef_cookbook?(path)
          raise CookbookNotFound, "Cookbook '#{name}' not found at path: '#{path}'"
        end

        path
      end

      def downloaded?(destination)
        if File.exists?(path) && File.chef_cookbook?(path)
          path
        else
          nil
        end
      end

      def to_s
        "path: '#{path}'"
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
        tmp_clone = Dir.mktmpdir
        ::KCD::Git.clone(uri, tmp_clone)
        ::KCD::Git.checkout(tmp_clone, branch) if branch
        unless branch
          self.branch = ::KCD::Git.rev_parse(tmp_clone)
        end

        unless File.chef_cookbook?(tmp_clone)
          msg = "Cookbook '#{name}' not found at git: #{uri}" 
          msg << " with branch '#{branch}'" if branch
          raise CookbookNotFound, msg
        end

        cb_path = File.join(destination, "#{self.name}-#{self.branch}")

        FileUtils.mv(tmp_clone, cb_path, :force => true)

        cb_path
      rescue KCD::GitError
        msg = "Cookbook '#{name}' not found at git: #{uri}" 
        msg << " with branch '#{branch}'" if branch
        raise CookbookNotFound, msg
      end

      def downloaded?(destination)
        cb_path = File.join(destination, "#{name}-#{branch}")
        if File.exists?(cb_path) && File.chef_cookbook?(cb_path)
          cb_path
        else
          nil
        end
      end

      def to_s
        s = "git: '#{uri}'"
        s << " with branch '#{branch}" if branch
        s
      end

      private

        def git
          @git ||= KCD::Git.new(uri)
        end
    end

    LOCATION_KEYS = [:git, :path, :site]

    attr_reader :name
    attr_reader :version_constraint
    attr_reader :groups
    attr_reader :location
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

      if (options.keys & LOCATION_KEYS).length > 1
        raise ArgumentError, "Only one location key (#{LOCATION_KEYS.join(', ')}) may be specified"
      end

      options[:version_constraint] = version_constraint if version_constraint

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

    # @param [String] destination
    #   destination to download to
    #
    # @returns [Array]
    #   An array containing the status at index 0 and local path or error message in index 1
    #
    #   Example:
    #     [ :ok, "/tmp/nginx" ]
    #     [ :error, "Cookbook 'sparkle_motion' not found at site: http://cookbooks.opscode.com/api/v1/cookbooks" ]
    def download(destination)
      set_local_path location.download(destination)
      [ :ok, local_path ]
    rescue CookbookNotFound => e
      set_local_path = nil
      [ :error, e.message ]
    end

    def downloaded?(destination)
      set_local_path location.downloaded?(destination)
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
      groups.include?(group.to_sym)
    end

    def dependencies
      return nil unless metadata

      metadata.dependencies
    end

    def local_version
      return nil unless metadata

      metadata.version
    end

    def locked_version
      @locked_version || local_version
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
