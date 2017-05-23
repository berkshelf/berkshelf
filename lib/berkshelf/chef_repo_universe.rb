require "berkshelf/api_client/remote_cookbook"
require "ridley/chef/cookbook"

module Berkshelf
  # Shim to look like a Berkshelf::APIClient but for a chef repo folder.
  #
  # @since 6.1
  class ChefRepoUniverse
    def initialize(uri, **options)
      @uri = uri
      @path = options[:path]
      @options = options
    end

    def universe
      Dir.entries(cookbooks_path).sort.each_with_object([]) do |entry, cookbooks|
        next if entry[0] == "." # Skip hidden folders.
        entry_path = "#{cookbooks_path}/#{entry}"
        next unless File.directory?(entry_path) # Skip non-dirs.
        cookbook = begin
          Ridley::Chef::Cookbook.from_path(entry_path)
        rescue IOError
          next # It wasn't a cookbook.
        end
        cookbooks << Berkshelf::APIClient::RemoteCookbook.new(
          cookbook.cookbook_name,
          cookbook.version,
          location_type: "file_store",
          location_path: entry_path,
          dependencies: cookbook.metadata.dependencies
        )
      end
    end

    private

    def cookbooks_path
      if File.exist?("#{@path}/cookbooks")
        "#{@path}/cookbooks"
      else
        @path
      end
    end
  end
end
