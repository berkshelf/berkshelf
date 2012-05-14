module KnifeCookbookDependencies
  class MetaCookbook
    attr_reader :name, :dependencies

    def initialize(name, dependencies)
      @name = name
      @dependencies = dependencies
    end

    def versions
      @v ||= [DepSelector::Version.new('1.0.0')]
    end

    def latest_constrained_version
      versions.first
    end
  end
end
