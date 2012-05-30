require 'json'

module KnifeCookbookDependencies
  class CookbookSource
    # @internal
    module Location
      include EM::Deferrable

      attr_reader :name

      def initialize(name)
        @name = name
      end

      def async_download(path)
        raise NotImplemented, "Must implement on includer"
      end
    end

    # @internal
    class SiteLocation
      include Location

      attr_accessor :api_uri
      attr_accessor :target_version

      OPSCODE_COMMUNITY_API = 'http://cookbooks.opscode.com/api/v1/cookbooks'.freeze

      def initialize(name, options = {})
        @name = name
        @target_version = options[:version_string] || :latest
        @api_uri = options[:site] || OPSCODE_COMMUNITY_API
      end

      def async_download(path)
        uri = if target_version == :latest
          http = EventMachine::HttpRequest.new("#{api_uri}/#{name}").aget
          http.callback {
            begin
              @target_version = JSON.parse(http.response)['latest_version']
            rescue JSON::ParserError
              fail
            end
          }
          http.errback { fail }
        else
          uri_for_version(target_version)
        end

        api_req = EventMachine::HttpRequest.new(uri).aget
        api_req.callback {
          remote_file = JSON.parse(api_req.response)['file']

          file_req = EventMachine::HttpRequest.new(remote_file).aget
          file_req.callback {
            local_path = File.join(path, filename)
            file = File.new(local_path, "wb")
            EM.next_tick do
              file_req.stream { |chunk| file.write chunk }
            end
            succeed(local_path)
          }
          file_req.errback { fail }
        }
        api_req.errback { fail }
      end

      def filename
        "#{name}-#{target_version}.tar.gz"
      end

      private

        def uri_for_version(version)
          "#{api_uri}/#{name}/versions/#{uri_escape_version(version)}"
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

      def async_download(path)
        succeed(File.join(name, path))
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

      def async_download(path)
        local_path = File.join(path, name)
        clone = git.async_clone(local_path)
        clone.callback {
          if branch
            co = git.async_checkout(branch)
            co.callback { succeed(local_path) }
            co.errback { fail }
          else
            succeed(local_path)
          end
        }

        clone.errback { fail }
      end

      private

        def git
          @git ||= KCD::Git.new(uri)
        end
    end

    include EM::Deferrable

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

    def async_download(path)
      return succeed if downloaded?

      location.async_download(path)

      location.callback do |l_path|
        set_downloaded_status(true)
        set_local_path(l_path)
        succeed
      end
      location.errback { fail }
    end

    def downloaded?
      @downloaded_state
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
