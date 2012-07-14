module Berkshelf
  module DSL
    @@active_group = nil

    def cookbook(*args)
      source = CookbookSource.new(*args)
      source.add_group(@@active_group) if @@active_group
      add_source(source)
    end

    def group(*args)
      @@active_group = args
      yield
      @@active_group = nil
    end

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

      source = CookbookSource.new(name, path: File.dirname(metadata_file))
      add_source(source)
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

    def add_source(source)
      raise NotImplementedError, "Function must be implemented on includer"
    end

    def add_location(type, value, options)
      raise NotImplementedError, "Function must be implemented on includer"
    end

    private

      def filepath
        File.join(File.expand_path('.'), "DSLFile")
      end
  end
end
