module Berkshelf
  class CookbookSource
    # @author Jamie Winsor <jamie@vialstudios.com>
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
        # @return [Array, nil]
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

          nil
        end
      end

      # @param [#to_s] name
      # @param [DepSelector::VersionConstraint] version_constraint
      # @param [Hash] options
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
            solution = self.class.solve_for_constraint(version_constraint, versions)
            
            unless solution
              raise NoSolution, "No cookbook version of '#{name}' found at '#{api_uri}' that would satisfy constraint (#{version_constraint})."
            end

            solution
          else
            latest_version
          end
        end
    end
  end
end
