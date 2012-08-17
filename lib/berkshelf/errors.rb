module Berkshelf
  class BerkshelfError < StandardError
    class << self
      # @param [Integer] code
      def status_code(code)
        define_method(:status_code) { code }
        define_singleton_method(:status_code) { code }
      end
    end

    alias_method :message, :to_s
  end

  class InternalError < BerkshelfError; status_code(99); end
  class BerksfileNotFound < BerkshelfError; status_code(100); end
  class NoVersionForConstraints < BerkshelfError; status_code(101); end
  class DownloadFailure < BerkshelfError; status_code(102); end
  class CookbookNotFound < BerkshelfError; status_code(103); end
  class GitError < BerkshelfError
    status_code(104)
    attr_reader :stderr

    def initialize(stderr)
      @stderr = stderr
    end

    def to_s
      out = "An error occured during Git execution:\n"
      out << stderr.prepend_each("\n", "\t")
    end
  end

  class DuplicateSourceDefined < BerkshelfError; status_code(105); end
  class NoSolution < BerkshelfError; status_code(106); end
  class CookbookSyntaxError < BerkshelfError; status_code(107); end
  class UploadFailure < BerkshelfError; status_code(108); end
  class KnifeConfigNotFound < BerkshelfError; status_code(109); end

  class InvalidGitURI < BerkshelfError
    status_code(110)
    attr_reader :uri

    # @param [String] uri
    def initialize(uri)
      @uri = uri
    end

    def to_s
      "'#{uri}' is not a valid Git URI."
    end
  end

  class GitNotFound < BerkshelfError
    status_code(110)

    def to_s
      "Could not find a Git executable in your path. Please add it and try again."
    end
  end

  class ConstraintNotSatisfied < BerkshelfError; status_code(111); end
  class InvalidChefAPILocation < BerkshelfError; status_code(112); end
  class BerksfileReadError < BerkshelfError
    def initialize(original_error)
      @original_error = original_error
    end

    status_code(113)

    def status_code
      @original_error ? @original_error.status_code : 113
    end
  end
end
