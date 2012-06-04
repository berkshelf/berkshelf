module KnifeCookbookDependencies
  class Lockfile
    class << self
      def remove!
        FileUtils.rm_f DEFAULT_FILENAME
      end
    end

    DEFAULT_FILENAME = "#{KCD::DEFAULT_FILENAME}.lock".freeze

    attr_reader :sources

    def initialize(sources)
      @sources = sources
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

        if source.location.is_a?(CookbookSource::GitLocation)
          definition += ", :git => '#{source.git_repo}', :ref => '#{source.git_ref || 'HEAD'}'"
        elsif source.location.is_a?(CookbookSource::PathLocation)
          definition += ", :path => '#{source.local_path}'"
        else
          definition += ", :locked_version => '#{source.locked_version}'"
        end

        return definition
      end
  end
end
