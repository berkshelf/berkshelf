module KnifeCookbookDependencies
  class CachedCookbook
    DIRNAME_REGEXP = /^(.+)-(\d+\.\d+\.\d+)$/

    class << self
      def from_path(path)
        return nil unless path.cookbook?
        
        matchdata = path.to_s.match(DIRNAME_REGEXP)
        return nil if matchdata.nil?

        name = matchdata[1]

        metadata = Chef::Cookbook::Metadata.new
        metadata.from_file(path.join("metadata.rb").to_s)
        metadata

        new(name, path, metadata)
      end
    end

    extend Forwardable

    attr_reader :name
    attr_reader :path

    def_delegators :@metadata, :version

    def initialize(name, path, metadata)
      @name = name
      @path = path
      @metadata = metadata
    end

    private

      attr_reader :metadata
  end
end
