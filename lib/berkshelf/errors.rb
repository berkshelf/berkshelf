module Berkshelf
  class BerkshelfError < StandardError
    class << self
      def status_code(code)
        define_method(:status_code) { code }
        define_singleton_method(:status_code) { code }
      end
    end
  end

  class BerksfileNotFound < BerkshelfError; status_code(100); end
  class NoVersionForConstraints < BerkshelfError; status_code(101); end
  class DownloadFailure < BerkshelfError; status_code(102); end
  class CookbookNotFound < BerkshelfError; status_code(103); end
  class GitError < BerkshelfError; status_code(104); end
  class DuplicateSourceDefined < BerkshelfError; status_code(105); end
  class NoSolution < BerkshelfError; status_code(106); end
  class CookbookSyntaxError < BerkshelfError; status_code(107); end
  class UploadFailure < BerkshelfError; status_code(108); end
end
