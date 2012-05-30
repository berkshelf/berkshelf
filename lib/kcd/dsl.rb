module KnifeCookbookDependencies
  module DSL
    def cookbook(*args)
      source = CookbookSource.new(*args)
      KCD.shelf.add_source(source)
    end

    def group(*args)
      KCD.shelf.active_group = args
      yield
      KCD.shelf.active_group = nil
    end

    def metadata(options = {})
      path = options[:path] || File.expand_path('.')

      metadata_file = KCD.find_metadata(path)

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

      source = CookbookSource.new(name, :path => File.dirname(metadata_file))
      KCD.shelf.add_source(source)
    end
  end
end
