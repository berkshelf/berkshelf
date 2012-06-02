module KnifeCookbookDependencies
  class Downloader
    class ResultSet
      attr_reader :results

      def initialize
        @results = []
      end

      def add_result(result)
        @results << result
      end

      def failed
        results.select { |result| result.status == :error }
      end

      def success
        results.select { |result| result.status == :ok }
      end

      def has_errors?
        !failed.empty?
      end
    end

    class Result
      attr_reader :source
      attr_reader :status
      attr_reader :message

      def initialize(source, status, message)
        @source = source
        @status = status
        @message = message
      end
    end

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
    # @return [Downloader::ResultSet]
    #   a ResultSet containing instaces of Downloader::Result
    def download_all
      results = ResultSet.new

      queue.each do |source|
        status, message = source.download(storage_path)
        results.add_result Result.new(source, status, message)
      end

      results.success.each { |result| dequeue(result.source) }
      
      results
    end

    private

      def validate_source(source)
        source.is_a?(KCD::CookbookSource)
      end
  end
end
