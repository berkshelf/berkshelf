require 'berkshelf/cookbook_source/location'

module Berkshelf
  class CookbookSource
    # @author Jamie Winsor <jamie@vialstudios.com>
    class SiteLocation
      include Location

      location_key :site

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
      end

      # @param [#to_s] name
      # @param [Solve::Constraint] version_constraint
      # @param [Hash] options
      #
      # @option options [String] :site
      #   a URL pointing to a community API endpoint
      def initialize(name, version_constraint, options = {})
        options[:site] ||= OPSCODE_COMMUNITY_API

        @name = name
        @version_constraint = version_constraint
        @api_uri = options[:site]
      end

      # @param [#to_s] destination
      #
      # @return [Berkshelf::CachedCookbook]
      def download(destination)
        version, uri = target_version
        remote_file = rest.get_rest(uri)['file']

        downloaded_tf = rest.get_rest(remote_file, true)

        dir = Dir.mktmpdir
        cb_path = File.join(destination, "#{name}-#{version}")

        self.class.unpack(downloaded_tf.path, dir)
        FileUtils.mv(File.join(dir, name), cb_path, force: true)

        cached = CachedCookbook.from_store_path(cb_path)
        validate_cached(cached)
        
        set_downloaded_status(true)
        cached
      end

      # @return [Array]
      #   an Array where the first element is a Solve::Version representing the latest version of
      #   the Cookbook and the second element is the URI to where the corrosponding version of the
      #   Cookbook can be downloaded from
      #
      #   Example:
      #       [ 0.101.2, "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_101_2" ]
      def version(version_string)
        quietly {
          result = rest.get_rest("#{name}/versions/#{uri_escape_version(version_string)}")
          dep_ver = Solve::Version.new(result['version'])

          [ dep_ver, result['file'] ]
        }
      rescue Net::HTTPServerException => e
        if e.response.code == "404"
          raise CookbookNotFound, "Cookbook name: '#{name}' version: '#{version_string}' not found at site: '#{api_uri}'"
        else
          raise
        end
      end

      # Returns a hash of all the cookbook versions found at communite site URL for the cookbook
      # name of this location.
      #
      # @example
      #   { 
      #     "0.101.2" => "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_101_2",
      #     "0.101.0" => "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_101_0"
      #   }
      #
      # @return [Hash]
      #   a hash representing the cookbook versions on at a Chef API for location's cookbook.
      #   The keys are version strings and the values are URLs to download the cookbook version.
      def versions
        versions = Hash.new
        quietly {
          rest.get_rest(name)['versions'].each do |uri|
            version_string = version_from_uri(File.basename(uri))
            version = Solve::Version.new(version_string)

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

      # Returns the latest version of the cookbook and it's download link.
      #
      # @example
      #   [ "0.101.2" => "https://api.opscode.com/organizations/vialstudios/cookbooks/nginx/0.101.2" ]
      #
      # @return [Array]
      #   an array containing the version and download URL for the cookbook version that
      #   should be downloaded for this location.
      def latest_version
        quietly {
          uri = rest.get_rest(name)['latest_version']

          [ version_from_uri(uri), uri ]
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

        # Returns an array containing the version and download URL for the cookbook version that
        # should be downloaded for this location.
        #
        # @example
        #   [ "0.101.2" => "https://api.opscode.com/organizations/vialstudios/cookbooks/nginx/0.101.2" ]
        #
        # @return [Array]
        def target_version
          if version_constraint
            solution = self.class.solve_for_constraint(version_constraint, versions)
            
            unless solution
              raise NoSolution, "No cookbook version of '#{name}' found at #{self} that would satisfy constraint (#{version_constraint})."
            end

            solution
          else
            latest_version
          end
        end
    end
  end
end
