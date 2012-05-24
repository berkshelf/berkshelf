module KnifeCookbookDependencies
  class KCDError < StandardError
    class << self
      def status_code(code)
        define_method(:status_code) { code }
      end
    end
  end

  class CookbookfileNotFound < KCDError; status_code(100); end
end
