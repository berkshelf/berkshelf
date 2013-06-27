require 'fileutils'

module Berkshelf
  class CookbookStore
    class << self
      def instance
        @instance ||= new(Berkshelf.cookbooks_dir)
      end

      def import(name, version, path)
        instance.import(name, version, path)
      end
    end

    # @return [String]
    #   filepath to where cookbooks are stored
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

    def import(name, version, path)
      import_validate(name, version, path)
      FileUtils.mv(path, cookbook_path(name, version))
      cookbook(name, version)
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
    # storage_path of this instance of CookbookStore.
    #
    # @param [String] filter
    #   return only the CachedCookbooks whose name match the given filter
    #
    # @return [Array<Berkshelf::CachedCookbook>]
    def cookbooks(filter = nil)
      cookbooks = []

      storage_path.each_child.map do |path|
        Celluloid::Future.new do
          cached_cookbook = CachedCookbook.from_store_path(path)

          next unless cached_cookbook
          next if filter && cached_cookbook.cookbook_name != filter

          cookbooks << cached_cookbook
        end
      end.each(&:value)

      cookbooks
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

      name, version = Solve.it!(graph, [[name, constraint]]).first

      cookbook(name, version)
    rescue Solve::Errors::NoSolutionError
      nil
    end

    private

      def import_validate(name, version, path)
        true
      end

      def initialize_filesystem
        FileUtils.mkdir_p(storage_path, mode: 0755)

        unless File.writable?(storage_path)
          raise InsufficientPrivledges, "You do not have permission to write to '#{storage_path}'! Please either chown the directory or use a different Cookbook Store."
        end
      end
  end
end
