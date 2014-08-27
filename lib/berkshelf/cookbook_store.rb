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
      skipped_cookbooks = []
      cookbooks = storage_path.children.collect do |path|
        begin
          Semverse::Version.split(File.basename(path).slice(CachedCookbook::DIRNAME_REGEXP, 2))
        rescue Semverse::InvalidVersionFormat
          # Skip cookbooks that were downloaded by an SCM location. These can not be considered
          # complete cookbooks.
          next
        end

        begin
          CachedCookbook.from_store_path(path)
        rescue Ridley::Errors::MissingNameAttribute
          # Skip cached cookbooks that do not have a name attribute.
          skipped_cookbooks << File.basename(path)
          next
        end
      end.compact

      if skipped_cookbooks.any?
        msg = "Skipping cookbooks #{skipped_cookbooks}. Berkshelf can only interact "
        msg << "with cookbooks which have defined the `name` attribute in their metadata.rb. If you "
        msg << "are the maintainer of any of the above cookbooks, please add the name attribute to "
        msg << "your cookbook. If you are not the maintainer, please file an issue or report the lack "
        msg << "of a name attribute as a bug.\n\n"
        msg << "You can remove each cookbook in #{skipped_cookbooks} from the Berkshelf shelf "
        msg << "by using the `berks shelf uninstall` command:\n\n"
        msg << "    $ berks shelf uninstall <name>"
        Berkshelf.log.warn msg
      end

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
    # @param [Semverse::Constraint] constraint
    #
    # @return [Berkshelf::CachedCookbook, nil]
    def satisfy(name, constraint)
      graph = Solve::Graph.new
      cookbooks(name).each { |cookbook| graph.artifact(name, cookbook.version) }

      name, version = Solve.it!(graph, [[name, constraint]], ENV['DEBUG_RESOLVER'] ? { ui: Berkshelf.ui } : {}).first

      cookbook(name, version)
    rescue Solve::Errors::NoSolutionError
      nil
    end
  end
end
