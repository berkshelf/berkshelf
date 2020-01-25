require "chef/cookbook/cookbook_version_loader"
require "chef/cookbook/syntax_check"
require_relative "errors"
require "chef/json_compat"

module Berkshelf
  class CachedCookbook
    class << self
      # @param [#to_s] path
      #   a path on disk to the location of a Cookbook downloaded by the Downloader
      #
      # @return [CachedCookbook]
      #   an instance of CachedCookbook initialized by the contents found at the
      #   given path.
      def from_store_path(path)
        path        = Pathname.new(path)
        cached_name = File.basename(path.to_s).slice(DIRNAME_REGEXP, 1)
        return nil if cached_name.nil?

        loaded_cookbooks[path.to_s] ||= from_path(path)
      end

      # Creates a new instance of Berkshelf::CachedCookbook from a path on disk containing
      # a Cookbook.
      #
      # The name of the Cookbook is determined by the value of the name attribute set in
      # the cookbooks' metadata. If the name attribute is not present the name of the loaded
      # cookbook is determined by directory containing the cookbook.
      #
      # @param [#to_s] path
      #   a path on disk to the location of a Cookbook
      #
      # @raise [IOError] if the path does not contain a metadata.rb or metadata.json file
      #
      # @return [Ridley::Chef::Cookbook]
      def from_path(path)
        path = Pathname.new(path)

        new(path)
      end

      def checksum(filepath)
        Chef::Digester.generate_md5_checksum_for_file(filepath)
      end

      private

      # @return [Hash<String, CachedCookbook>]
      def loaded_cookbooks
        @loaded_cookbooks ||= {}
      end
    end

    attr_writer :metadata
    attr_accessor :path
    attr_writer :cookbook_version

    def initialize(path)
      @path = path
      # eagerly load to force throwing on bad metadata while constructing
      cookbook_name
      metadata
    end

    def loader
      @loader ||=
        begin
          loader = Chef::Cookbook::CookbookVersionLoader.new(@path)
          loader.load!
          loader
        end
    end

    def cookbook_version
      @cookbook_version ||= loader.cookbook_version
    end

    def cookbook_name
      @cookbook_name ||= cookbook_version.name
    end

    def metadata
      @metadata ||= cookbook_version.metadata
    end

    def reload
      @metadata = nil
      @cookbook_name = nil
      @cookbook_version = nil
      @loader = nil
    end

    def <=>(other)
      [cookbook_name, version] <=> [other.cookbook_name, other.version]
    end

    DIRNAME_REGEXP = /^(.+)-(.+)$/.freeze

    extend Forwardable

    def_delegator :cookbook_version, :version
    def_delegator :metadata, :name, :cookbook_name
    def_delegator :metadata, :description
    def_delegator :metadata, :maintainer
    def_delegator :metadata, :maintainer_email
    def_delegator :metadata, :license
    def_delegator :metadata, :platforms
    def_delegator :metadata, :name

    # @return [Hash]
    def dependencies
      metadata.dependencies
    end

    def pretty_print
      [].tap do |a|
        a.push "        Name: #{cookbook_name}" if name && name =~ /\S/
        a.push "     Version: #{version}" if version && version =~ /\S/
        a.push " Description: #{metadata.description}" if metadata.description && metadata.description =~ /\S/
        a.push "      Author: #{metadata.maintainer}" if metadata.maintainer && metadata.maintainer =~ /\S/
        a.push "       Email: #{metadata.maintainer_email}" if metadata.maintainer_email && metadata.maintainer_email =~ /\S/
        a.push "     License: #{metadata.license}" if metadata.license && metadata.license =~ /\S/
        a.push "   Platforms: #{pretty_map(metadata.platforms, 14)}" if metadata.platforms && !metadata.platforms.empty?
        a.push "Dependencies: #{pretty_map(dependencies, 14)}" if dependencies && !dependencies.empty?
      end.join("\n")
    end

    # High-level information about this cached cookbook in JSON format
    #
    # @return [String]
    def pretty_json
      JSON.pretty_generate(pretty_hash)
    end

    # High-level information about this cached cookbook in Hash format
    #
    # @return [Hash]
    def pretty_hash
      {}.tap do |h|
        h[:name]          = cookbook_name if cookbook_name && cookbook_name =~ /\S/
        h[:version]       = version if version && version =~ /\S/
        h[:description]   = description if description && description =~ /\S/
        h[:author]        = maintainer if maintainer && maintainer =~ /\S/
        h[:email]         = maintainer_email if maintainer_email && maintainer_email =~ /\S/
        h[:license]       = license if license && license =~ /\S/
        h[:platforms]     = platforms.to_hash if platforms && !platforms.empty?
        h[:dependencies]  = dependencies.to_hash if dependencies && !dependencies.empty?
      end
    end

    def validate
      raise IOError, "No Cookbook found at: #{path}" unless path.exist?

      syntax_checker = Chef::Cookbook::SyntaxCheck.new(path.to_path)

      unless syntax_checker.validate_ruby_files
        raise Berkshelf::Errors::CookbookSyntaxError, "Invalid ruby files in cookbook: #{cookbook_name} (#{version})."
      end
      unless syntax_checker.validate_templates
        raise Berkshelf::Errors::CookbookSyntaxError, "Invalid template files in cookbook: #{cookbook_name} (#{version})."
      end

      true
    end

    def compile_metadata(path = self.path)
      json_file = "#{path}/metadata.json"
      rb_file = "#{path}/metadata.rb"
      return nil if File.exist?(json_file)

      md = Chef::Cookbook::Metadata.new
      md.from_file(rb_file)
      f = File.open(json_file, "w")
      f.write(Chef::JSONCompat.to_json_pretty(md))
      f.close
      f.path
    end

    private

    def pretty_map(hash, padding)
      hash.map { |k, v| "#{k} (#{v})" }.join("\n" + " " * padding)
    end
  end
end
