module KnifeCookbookDependencies
  class KCDError < StandardError
    class << self
      def status_code(code)
        define_method(:status_code) { code }
      end
    end
  end

  class CookbookfileNotFound < KCDError; status_code(100); end
  class NoVersionForConstraints < KCDError; status_code(101); end
  class RemoteCookbookNotFound < KCDError; status_code(102); end
end
