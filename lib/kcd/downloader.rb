module KnifeCookbookDependencies
  class Downloader
    attr_reader :storage_path
    attr_reader :queue
    attr_accessor :concurrency

    def initialize(storage_path, concurrency = 6)
      @storage_path = storage_path
      @concurrency = concurrency
      @queue = []
    end

    # Add a CookbookSource to the downloader's queue
    #
    # @param [KCD::CookbookSource] source
    # 
    # @return [Array<KCD::CookbookSource>]
    #   the queue - an array of KCD::CookbookSources
    def enqueue(source)
      unless validate_source(source)
        raise ArgumentError, "Invalid CookbookSource: can only enqueue valid instances of CookbookSource."
      end

      @queue << source
    end

    # Remove a CookbookSource from the downloader's queue
    #
    # @param [KCD::CookbookSource] source
    #
    # @return [KCD::CookbookSource]
    #   the CookbookSource removed from the queue
    def dequeue(source)
      @queue.delete(source)
    end

    # Download each CookbookSource in the queue. Upon successful download
    # of a CookbookSource it is removed from the queue. If a CookbookSource
    # fails to download it remains in the queue.
    #
    # @return [Hash]
    #   a hash containing sources downloaded and their result set. Keys
    #   are CookbookSource objects with a Hash containing the status and
    #   result value for each CookbookSource key.
    #
    #   Example:
    #     { 
    #       #<CookbookSource:1> => {
    #         :status => :ok,
    #         :value => "/tmp/path_to_source/nginx"
    #       }
    #     }
    def download_all
      results = Hash.new

      queue.each do |source|
        status, value = source.download(storage_path)
        results[source] = { :status => status, :value => value }
      end

      results.each { |source, result| dequeue(source) if result[:status] == :ok }
      
      results
    end

    private

      def validate_source(source)
        source.is_a?(KCD::CookbookSource)
      end
  end
end
