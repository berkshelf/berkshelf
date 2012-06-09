module KnifeCookbookDependencies
  class TXResultSet
    attr_reader :results

    def initialize
      @results = []
    end

    def add_result(result)
      unless validate_result(result)
        raise ArgumentError, "Invalid Result: results must respond to :failed? and :success?"
      end

      @results << result
    end

    def failed
      results.select { |result| result.failed? }
    end

    def success
      results.select { |result| result.success? }
    end

    def has_errors?
      !failed.empty?
    end

    private

      def validate_result(result)
        result.respond_to?(:failed?) &&
          result.respond_to?(:success?)
      end
  end
end
