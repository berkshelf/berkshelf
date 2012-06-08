require 'fileutils'

module KnifeCookbookDependencies
  class Downloader
    attr_reader :storage_path
    attr_reader :queue

    def initialize(storage_path)
      @storage_path = storage_path
      @queue = []
      initialize_store
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
    # @return [Downloader::TXResultSet]
    #   a TXResultSet containing instaces of Downloader::Result
    def download_all
      results = TXResultSet.new

      queue.each do |source|
        results.add_result download(source)
      end

      results.success.each { |result| dequeue(result.source) }
      
      results
    end

    def download(source)
      status, message = source.download(storage_path)
      TXResult.new(source, status, message)
    end

    def download!(source)
      result = download(source)
      raise DownloadFailure.new(result) if result.failed?
      
      result
    end

    def downloaded?(source)
      source.downloaded?(storage_path)
    end

    private

      def initialize_store
        FileUtils.mkdir_p(storage_path, :mode => 0755)
      end

      def validate_source(source)
        source.is_a?(KCD::CookbookSource)
      end
  end
end
