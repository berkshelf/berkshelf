require 'fileutils'

module Berkshelf
  class CookbookStore
    class << self
      # The default path to the cookbook store relative to the Berkshelf path.
      #
      # @return [String]
      def default_path
        File.join(Berkshelf.berkshelf_path, 'cookbooks')
      end

      # @return [Berkshelf::CookbookStore]
      def instance
        @instance ||= new(default_path)
      end

      # Import a cookbook found on the local filesystem into the current instance of
      # the cookbook store.
      #
      # @param [String] name
      #   name of the cookbook
      # @param [String] version
      #   verison of the cookbook
      # @param [String] path
      #   location on disk of the cookbook
      #
      # @return [Berkshelf::CachedCookbook]
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

    # Destroy the contents of the initialized storage path.
    def clean!
      FileUtils.rm_rf(Dir.glob(File.join(storage_path, '*')))
    end

    # Import a cookbook found on the local filesystem into this instance of the cookbook store.
    #
    # @param [String] name
    #   name of the cookbook
    # @param [String] version
    #   verison of the cookbook
    # @param [String] path
    #   location on disk of the cookbook
    #
    # @return [Berkshelf::CachedCookbook]
    def import(name, version, path)
      destination = cookbook_path(name, version)
      FileUtils.mv(path, destination)
      cookbook(name, version)
    rescue => ex
      FileUtils.rm_f(destination)
      raise
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
    # @param [String, Regexp] filter
    #   return only the CachedCookbooks whose name match the given filter
    #
    # @return [Array<Berkshelf::CachedCookbook>]
    def cookbooks(filter = nil)
      cookbooks = storage_path.children.collect do |path|
        begin
          Solve::Version.split(File.basename(path).slice(CachedCookbook::DIRNAME_REGEXP, 2))
        rescue Solve::Errors::InvalidVersionFormat
          # Skip cookbooks that were downloaded by an SCM location. These can not be considered
          # complete cookbooks.
          next
        end

        CachedCookbook.from_store_path(path)
      end.compact

      return cookbooks unless filter

      cookbooks.select do |cookbook|
        filter === cookbook.cookbook_name
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

    def initialize_filesystem
      FileUtils.mkdir_p(storage_path, mode: 0755)

      unless File.writable?(storage_path)
        raise InsufficientPrivledges.new(storage_path)
      end
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

      name, version = Solve.it!(graph, [[name, constraint]], ENV['DEBUG_RESOLVER'] ? { ui: Berkshelf.ui } : {}).first

      cookbook(name, version)
    rescue Solve::Errors::NoSolutionError
      nil
    end
  end
end
