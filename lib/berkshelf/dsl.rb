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

    def site(uri)
      if uri == :opscode
        uri = CookbookSource::SiteLocation::OPSCODE_COMMUNITY_API
      end

      add_location(:site, uri)
    end

    def chef_api(uri, options = {})
      add_location(:chef_api, uri, options)
    end

    private

      def filepath
        File.join(File.expand_path('.'), "DSLFile")
      end
  end
end
