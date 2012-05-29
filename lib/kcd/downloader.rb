require 'em-synchrony'
require 'em-synchrony/em-http'

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

    # Add a CookbooKSource to the downloader's queue
    #
    # @param [KCD::CookbookSource] source
    # 
    # @return [Array<KCD::ookbookSource>]
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

    def download
      EM.synchrony do
        results = EM::Synchrony::Iterator.new(queue, concurrency).map do |source, iter|
          result = source.async_download(storage_path)

          result.callback do
            dequeue(source)
            iter.return(result)
          end

          result.errback { iter.return(result) }
        end

        EventMachine.stop
        results
      end
    end

    private

      def validate_source(source)
        source.is_a?(KCD::CookbookSource)
      end
  end
end
