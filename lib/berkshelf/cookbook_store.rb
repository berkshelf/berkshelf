require 'fileutils'

module Berkshelf
  # @author Jamie Winsor <jamie@vialstudios.com>
  class CookbookStore
    attr_reader :storage_path

    # Create a new instance of CookbookStore with the given
    # storage_path.
    #
    # @param [String] storage_path
    #   local filesystem path to the location to be initialized
    #   as a CookbookStore.
    def initialize(storage_path)
      @storage_path = Pathname.new(storage_path)
      initialize_filesystem
    end

    # Returns an instance of CachedCookbook representing the
    # Cookbook of your given name and version.
    #
    # @param [String] name
    #   name of the Cookbook you want to retrieve
    # @param [String] version
    #   version of the Cookbook you want to retrieve
    #
    # @return [Berkshelf::CachedCookbook, nil]
    def cookbook(name, version)
      path = cookbook_path(name, version)
      return nil unless path.cookbook?

      CachedCookbook.from_store_path(path)
    end

    # Returns an array of the Cookbooks that have been cached to the
    # storage_path of this instance of CookbookStore. Passing the filter
    # option will return only the CachedCookbooks whose name match the
    # filter.
    #
    # @return [Array<Berkshelf::CachedCookbook>]
    def cookbooks(filter = nil)
      [].tap do |cookbooks|
        storage_path.each_child do |p|
          cached_cookbook = CachedCookbook.from_store_path(p)
          
          next unless cached_cookbook
          next if filter && cached_cookbook.cookbook_name != filter

          cookbooks << cached_cookbook
        end
      end
    end

    # Returns an expanded path to the location on disk where the Cookbook
    # of the given name and version is located.
    #
    # @param [String] name
    # @param [String] version
    #
    # @return [Pathname]
    def cookbook_path(name, version)
      storage_path.join("#{name}-#{version}")
    end

    # Return a CachedCookbook matching the best solution for the given name and
    # constraint. Nil is returned if no matching CachedCookbook is found.
    #
    # @param [#to_s] name
    # @param [Solve::Constraint] constraint
    #
    # @return [Berkshelf::CachedCookbook, nil]
    def satisfy(name, constraint)
      graph = Solve::Graph.new
      cookbooks(name).each { |cookbook| graph.artifacts(name, cookbook.version) }
      graph.demands(name, constraint)

      name, version = Solve.it!(graph).first
      
      cookbook(name, version)
    rescue Solve::NoSolutionError
      nil
    end

    private

      def initialize_filesystem
        FileUtils.mkdir_p(storage_path, mode: 0755)
      end
  end
end
