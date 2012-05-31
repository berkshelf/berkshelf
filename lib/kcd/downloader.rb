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
      @queue.delete(source) { "not found: source "}
    end

    def download_all
      results = Hash.new

      queue.each do |source|
        begin
          if source.download(storage_path)
            results[source] = :ok
          else
            results[source] = :error
          end
        rescue Net::HTTPServerException
          results[source] = :error
        end
      end

      results.each { |source, status| dequeue(source) if status == :ok }
      
      results
    end

    def async_download
      results = nil
      EM.synchrony do
        results = EM::Synchrony::Iterator.new(queue, concurrency).map do |source, iter|
          source.async_download(storage_path)

          source.callback do
            dequeue(source)
            iter.return(source)
          end

          source.errback { iter.return(source) }
        end

        EventMachine.stop
      end
      
      results
    end

    private

      def validate_source(source)
        source.is_a?(KCD::CookbookSource)
      end
  end
end
