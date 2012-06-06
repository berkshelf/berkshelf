module KnifeCookbookDependencies
  class KCDError < StandardError
    class << self
      def status_code(code)
        define_method(:status_code) { code }
        define_singleton_method(:status_code) { code }
      end
    end
  end

  class CookbookfileNotFound < KCDError; status_code(100); end
  class NoVersionForConstraints < KCDError; status_code(101); end

  class DownloadFailure < KCDError
    status_code(102)

    attr_reader :errors

    def initialize(results)
      @errors = []

      Array(results).each do |result|
        @errors << result.message
      end
    end

    def message
      errors.join("\n")
    end
  end

  class CookbookNotFound < KCDError; status_code(103); end
  class GitError < KCDError; status_code(104); end
  class DuplicateSourceDefined < KCDError; status_code(105); end
  class NoSolution < KCDError; status_code(106); end
end
