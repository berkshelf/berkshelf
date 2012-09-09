module Berkshelf
  module DSL
    @@active_group = nil

    # @overload cookbook(name, version_constraint, options = {})
    #   @param [#to_s] name
    #   @param [#to_s] version_constraint
    #   @param [Hash] options
    #
    #   @option options [Symbol, Array] :group
    #     the group or groups that the cookbook belongs to
    #   @option options [String, Symbol] :chef_api
    #     a URL to a Chef API. Alternatively the symbol :knife can be provided
    #     which will instantiate this location with the values found in your
    #     knife configuration.
    #   @option options [String] :site
    #     a URL pointing to a community API endpoint
    #   @option options [String] :path
    #     a filepath to the cookbook on your local disk
    #   @option options [String] :git
    #     the Git URL to clone
    #
    #   @see ChefAPILocation
    #   @see SiteLocation
    #   @see PathLocation
    #   @see GitLocation
    # @overload cookbook(name, options = {})
    #   @param [#to_s] name
    #   @param [Hash] options
    #
    #   @option options [Symbol, Array] :group
    #     the group or groups that the cookbook belongs to
    #   @option options [String, Symbol] :chef_api
    #     a URL to a Chef API. Alternatively the symbol :knife can be provided
    #     which will instantiate this location with the values found in your
    #     knife configuration.
    #   @option options [String] :site
    #     a URL pointing to a community API endpoint
    #   @option options [String] :path
    #     a filepath to the cookbook on your local disk
    #   @option options [String] :git
    #     the Git URL to clone
    #
    #   @see ChefAPILocation
    #   @see SiteLocation
    #   @see PathLocation
    #   @see GitLocation
    def cookbook(*args)
      options = args.last.is_a?(Hash) ? args.pop : Hash.new
      name, constraint = args

      options[:group] = Array(options[:group])
      
      if @@active_group
        options[:group] += @@active_group
      end

      add_source(name, constraint, options)
    end

    def group(*args)
      @@active_group = args
      yield
      @@active_group = nil
    end

    # @param [Hash] options
    #
    # @option options [String] :path
    #   path to the metadata file
    def metadata(options = {})
      path = options[:path] || File.dirname(filepath)

      metadata_file = Berkshelf.find_metadata(path)

      unless metadata_file
        raise CookbookNotFound, "No 'metadata.rb' found at #{path}"
      end

      metadata = Chef::Cookbook::Metadata.new
      metadata.from_file(metadata_file.to_s)

      name = if metadata.name.empty? || metadata.name.nil?
        File.basename(File.dirname(metadata_file))
      else
        metadata.name
      end

      constraint = "= #{metadata.version}"

      add_source(name, constraint, path: File.dirname(metadata_file))
    end

    # @param [String, Symbol] value
    #
    # @return [Hash]
    def site(value)
      add_location(:site, value)
    end

    # @param [String, Symbol] value
    # @param [Hash] options
    #
    # @return [Hash]
    def chef_api(value, options = {})
      add_location(:chef_api, value, options)
    end

    def add_source(name, constraint, options)
      raise AbstractFunction
    end

    def add_location(type, value, options)
      raise AbstractFunction
    end

    private

      def filepath
        File.join(File.expand_path('.'), "DSLFile")
      end
  end
end
