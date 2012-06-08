module KnifeCookbookDependencies
  class TXResultSet
    attr_reader :results

    def initialize
      @results = []
    end

    def add_result(result)
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
  end
end
