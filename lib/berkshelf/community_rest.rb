require_relative 'rest_adapter'

module Berkshelf
  class CommunityREST < RESTAdapter
    # The Community Site API endpoint
    V1_API = 'https://cookbooks.opscode.com/api/v1'.freeze

    def initialize
      super(V1_API)
    end

    #
    # Download the cookbook from the community site.
    #
    # @param [String] name
    #   the name of the cookbook to download
    # @param [String] version
    #   the version of the cookbook to download
    #
    # @return [String]
    #   the path where the extracted files live
    #
    def download(name, version)
      url = find(name, version)['file']
      response = get(url)

      case response.status
      when (200..299)
        begin
          io = Tempfile.new('package')
          io.binmode
          io.write(response.body)
          io.close(false)

          extracted = Extractor.new(io).unpack!
          Dir.glob(File.join(extracted, '*')).first
        ensure
          io.unlink unless io.nil?
        end
      when 404
        raise "Got a 404"
      else
        raise "Got a #{response.status}"
      end
    end

    #
    # Find a cookbook on the community site by the given name and version.
    #
    # @example fetch the +berkshelf+ cookbook
    #   find('berkshelf', '0.1.0') #=> { "file" => "http://s3.amazonaws..." }
    #
    # @param [String] name
    #   the name of the cookbook to download
    # @param [String] version
    #   the version of the cookbook to download
    #
    # @return [Hash]
    #   the parsed JSON response from the community site
    #
    def find(name, version)
      response = get("cookbooks/#{name}/versions/#{uri_escape_version(version)}")

      case response.status
      when (200..299)
        response.parsed
      when 404
        raise CookbookNotFound, "Cookbook '#{name}' (#{version}) not found!"
      else
        raise CommunitySiteError, "Error finding cookbook '#{name}' (#{version})!"
      end
    end

    #
    # Get the full list of versions for the given cookbook.
    #
    # @example get all versions of the +berkshelf+ cookbook
    #   versions('berkshelf') #=> ['1.0.0', '1.0.1']
    #
    # @param [String] name
    #
    # @return [Array<String>]
    #
    def versions(name)
      response = get("cookbooks/#{name}")

      case response.status
      when (200..299)
        response.parsed['versions'].map(&method(:version_from_uri))
      when 404
        raise CookbookNotFound, "Cookbook '#{name}' not found!"
      else
        raise CommunitySiteError, "Error retrieving versions of cookbook '#{name}'!"
      end
    end

    #
    # Returns the latest version of the cookbook and its download link.
    #
    # @example fetch the latest version of the +berkshelf+ cookbook
    #   latest_version('berkshelf') #=> "1.0.0"
    #
    # @return [String]
    #   the latest version of the cookbook
    #
    def latest_version(name)
      response = get("cookbooks/#{name}")

      case response.status
      when (200..299)
        version_from_uri(response.parsed['latest_version'])
      when 404
        raise CookbookNotFound, "Cookbook '#{name}' not found!"
      else
        raise CommunitySiteError, "Error retrieving latest version of cookbook '#{name}'!"
      end
    end

    private

      # @param [String] version
      #
      # @return [String]
      def uri_escape_version(version)
        version.to_s.gsub('.', '_')
      end

      # @param [String] uri
      #
      # @return [String]
      def version_from_uri(uri)
        File.basename(uri.to_s).gsub('_', '.')
      end
  end
end
