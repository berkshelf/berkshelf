module Berkshelf
  class Lockfile
    class << self
      def remove!
        FileUtils.rm_f DEFAULT_FILENAME
      end

      # @param [Array<CookbookSource>] sources
      def update!(sources)
        contents = File.readlines(DEFAULT_FILENAME)
        contents.delete_if do |line|
          line =~ /cookbook '(#{sources.map(&:name).join('|')})'/
        end

        contents += sources.map { |source| definition(source) }
        File.open(DEFAULT_FILENAME, 'wb') { |f| f.write(contents.join("\n").squeeze("\n")) }
      end

      # @param [CookbookSource] source
      #
      # @return [String]
      def definition(source)
        definition = "cookbook '#{source.name}'"

        if source.location.is_a?(GitLocation)
          definition += ", :git => '#{source.location.uri}', :ref => '#{source.location.branch || 'HEAD'}'"
        elsif source.location.is_a?(PathLocation)
          definition += ", :path => '#{source.location.path}'"
        else
          definition += ", :locked_version => '#{source.locked_version}'"
        end

        definition
      end
    end

    DEFAULT_FILENAME = "#{Berkshelf::DEFAULT_FILENAME}.lock".freeze

    attr_reader :sources

    def initialize(sources)
      @sources = Array(sources)
    end

    def write(filename = DEFAULT_FILENAME)
      content = sources.map { |source| self.class.definition(source) }.join("\n")
      File.open(filename, "wb") { |f| f.write content }
    end

    def remove!
      self.class.remove!
    end
  end
end
