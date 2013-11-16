module Berkshelf
  class Formatter
    class << self
      def find(name)
        {
          human: Berkshelf::Formatters::HumanFormatter,
          json:  Berkshelf::Formatters::JSONFormatter,
          null:  Berkshelf::Formatters::NullFormatter,
        }[name]
      end
    end

    # Run after the default tasks are completed.
    def cleanup_hook; end

    def error(*args); raise AbstractFunction; end

    def fetch(*args); raise AbstractFunction; end

    def install(*args); raise AbstractFunction; end

    def msg(*args); raise AbstractFunction; end

    def outdated(*args); raise AbstractFunction; end

    def package(*args); raise AbstractFunction; end

    def skip(*args); raise AbstractFunction; end

    def show(*args); raise AbstractFunction; end

    def upload(*args); raise AbstractFunction; end

    def use(*args); raise AbstractFunction; end

    def vendor(*args); raise AbstractFunction; end

    def version(*args); raise AbstractFunction; end
  end
end
