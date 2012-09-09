module Berkshelf
  # @author Jamie Winsor <jamie@vialstudios.com>
  class Downloader
    extend Forwardable

    DEFAULT_LOCATIONS = [
      {
        type: :site,
        value: :opscode,
        options: Hash.new
      }
    ].freeze

    # a filepath to download cookbook sources to
    #
    # @return [String]
    attr_reader :cookbook_store
    attr_reader :queue
    # an Array of Hashes representing each default location that can be used to attempt
    # to download cookbook sources which do not have an explicit location
    #
    # @return [Array<Hash>]
    attr_reader :locations

    def_delegators :@cookbook_store, :storage_path

    # @option options [Array<Hash>] locations
    def initialize(cookbook_store, options = {})
      @cookbook_store = cookbook_store
      @queue = Array.new
      @locations = options[:locations] || DEFAULT_LOCATIONS.dup
    end

    # Create a location hash and add it to the end of the array of locations.
    #
    # subject.add_location(:chef_api, "http://chef:8080", node_name: "reset", client_key: "/Users/reset/.chef/reset.pem") =>
    #   [ { type: :chef_api, value: "http://chef:8080/", node_name: "reset", client_key: "/Users/reset/.chef/reset.pem" } ]
    #
    # @param [Symbol] type
    # @param [String, Symbol] value
    # @param [Hash] options
    #
    # @return [Hash]
    def add_location(type, value, options = {})
      locations.push(type: type, value: value, options: options)
    end

    # Add a CookbookSource to the downloader's queue
    #
    # @param [Berkshelf::CookbookSource] source
    # 
    # @return [Array<Berkshelf::CookbookSource>]
    #   the queue - an array of Berkshelf::CookbookSources
    def enqueue(source)
      unless validate_source(source)
        raise ArgumentError, "Invalid CookbookSource: can only enqueue valid instances of CookbookSource."
      end

      @queue << source
    end

    # Remove a CookbookSource from the downloader's queue
    #
    # @param [Berkshelf::CookbookSource] source
    #
    # @return [Berkshelf::CookbookSource]
    #   the CookbookSource removed from the queue
    def dequeue(source)
      @queue.delete(source)
    end

    # Download each CookbookSource in the queue. Upon successful download
    # of a CookbookSource it is removed from the queue. If a CookbookSource
    # fails to download it remains in the queue.
    #
    # @return [TXResultSet]
    def download_all
      results = TXResultSet.new

      queue.each do |source|
        results.add_result download(source)
      end

      results.success.each { |result| dequeue(result.source) }
      
      results
    end

    # Downloads the given CookbookSource
    #
    # @param [CookbookSource] source
    #   the source to download
    #
    # @return [TXResult]
    def download(source)
      status, message = source.download(storage_path)
      TXResult.new(status, message, source)
    end

    # Downloads the given CookbookSource. Raises a DownloadFailure error
    # if the download was not successful.
    #
    # @param [CookbookSource] source
    #   the source to download
    #
    # @return [TXResult]
    def download!(source)
      result = download(source)
      raise DownloadFailure, result.message if result.failed?
      
      result
    end

    private

      def validate_source(source)
        source.is_a?(Berkshelf::CookbookSource)
      end
  end
end
