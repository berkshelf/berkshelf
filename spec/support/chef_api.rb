require 'pathname'
require 'chef/rest'
require 'chef/cookbook_version'

module Berkshelf
  module RSpec
    module ChefAPI
      # Return an array of Hashes containing cookbooks and their information
      #
      # @return [Array]
      def get_cookbooks
        rest.get_rest("cookbooks")
      end

      def upload_cookbook(path)
        cached = CachedCookbook.from_store_path(path)
        uploader.upload(cached)
      end

      # Remove all versions of all cookbooks from the Chef Server defined in your
      # Knife config.
      def purge_cookbooks
        get_cookbooks.each do |name, info|
          info["versions"].each do |version_info|
            rest.delete_rest("cookbooks/#{name}/#{version_info["version"]}?purge=true")
          end
        end
      end

      # Remove the version of the given cookbook from the Chef Server defined
      # in your Knife config.
      #
      # @param [#to_s] name
      # @param [#to_s] version
      def purge_cookbook(name, version)
        rest.delete_rest("cookbooks/#{name}/#{version}?purge=true")
      rescue Net::HTTPServerException => e
        raise unless e.to_s =~ /^404/
      end

      def server_has_cookbook?(name, version)
        rest.get_rest("cookbooks/#{name}/#{version}")
        true
      rescue Net::HTTPServerException => e
        false
      end

      def generate_cookbook(path, name, version, options = {})
        path = Pathname.new(path)
        cookbook_path = path.join("#{name}-#{version}")
        directories = [
          "recipes",
          "templates/default",
          "files/default",
          "attributes",
          "definitions",
          "providers",
          "resources"
        ]
        files = [
          "recipes/default.rb",
          "templates/default/template.erb",
          "files/default/file.h",
          "attributes/default.rb"
        ]

        directories.each do |directory|
          FileUtils.mkdir_p(cookbook_path.join(directory))
        end

        files.each do |file|
          FileUtils.touch(cookbook_path.join(file))
        end

        metadata = <<-EOF
name "#{name}"
version "#{version}"
EOF

        if options[:dependencies]
          options[:dependencies].each do |name, constraint|
            metadata << "depends '#{name}', '#{constraint}'\n"
          end
        end

        if options[:recommendations]
          options[:recommendations].each do |name, constraint|
            metadata << "recommends '#{name}', '#{constraint}'\n"
          end
        end

        File.open(cookbook_path.join("metadata.rb"), 'w+') do |f|
          f.write metadata
        end
        
        cookbook_path
      end

      private

        def rest
          quietly { ::Chef::REST.new(Chef::Config[:chef_server_url]) }
        end

        def uploader
          @uploader ||= Berkshelf::Uploader.new(
            server_url: ::Chef::Config[:chef_server_url],
            client_name: ::Chef::Config[:node_name],
            client_key: ::Chef::Config[:client_key]
          )
        end
    end
  end
end
