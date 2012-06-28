require 'pathname'
require 'chef/rest'
require 'chef/cookbook_version'

module Berkshelf
  module RSpec
    module ChefAPI
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

      def generate_cookbook(path, name, version)
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
        File.write(cookbook_path.join("metadata.rb"), metadata)
      end

      private

        def rest
          quietly { Chef::REST.new(Chef::Config[:chef_server_url]) }
        end
    end
  end
end
