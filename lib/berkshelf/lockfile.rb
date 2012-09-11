module Berkshelf
  class Lockfile
    class << self
      def remove!
        FileUtils.rm_f DEFAULT_FILENAME
      end
    end

    DEFAULT_FILENAME = "#{Berkshelf::DEFAULT_FILENAME}.lock".freeze

    attr_reader :sources

    def initialize(sources)
      @sources = Array(sources)
    end

    def write(filename = DEFAULT_FILENAME)
      content = sources.map { |source| get_source_definition(source) }.join("\n")
      File.open(filename, "wb") { |f| f.write content }
    end

    def remove!
      self.class.remove!
    end

    private

      def get_source_definition(source)
        definition = "cookbook '#{source.name}'"

        if source.location.is_a?(GitLocation)
          definition += ", :git => '#{source.location.uri}', :ref => '#{source.location.branch || 'HEAD'}'"
        elsif source.location.is_a?(PathLocation)
          definition += ", :path => '#{source.location.path}'"
        else
          definition += ", :locked_version => '#{source.locked_version}'"
        end

        return definition
      end
  end
end
