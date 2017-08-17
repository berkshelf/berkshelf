require "chef/cookbook/cookbook_version_loader"
require "chef/cookbook/syntax_check"
require "berkshelf/errors"
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

        new(nil, path, nil)
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

    attr_accessor :metadata
    attr_accessor :path
    attr_accessor :cookbook_version

    # name and metadata are now ignored and should be removed
    def initialize(name, path, metadata)
      loader = Chef::Cookbook::CookbookVersionLoader.new(path)
      loader.load_cookbooks
      @path = path
      @cookbook_version = loader.cookbook_version
      @cookbook_name = @cookbook_version.name
      @metadata = @cookbook_version.metadata
    end

    def <=>(other)
      [cookbook_name, version] <=> [other.cookbook_name, other.version]
    end

    DIRNAME_REGEXP = /^(.+)-(.+)$/

    extend Forwardable

    def_delegator :@cookbook_version, :version
    def_delegator :@metadata, :name, :cookbook_name
    def_delegator :@metadata, :description
    def_delegator :@metadata, :maintainer
    def_delegator :@metadata, :maintainer_email
    def_delegator :@metadata, :license
    def_delegator :@metadata, :platforms
    def_delegator :@metadata, :name

    # @return [Hash]
    def dependencies
      metadata.dependencies
    end

    def pretty_print
      [].tap do |a|
        a.push "        Name: #{cookbook_name}" unless name.blank?
        a.push "     Version: #{version}" unless version.blank?
        a.push " Description: #{metadata.description}" unless metadata.description.blank?
        a.push "      Author: #{metadata.maintainer}" unless metadata.maintainer.blank?
        a.push "       Email: #{metadata.maintainer_email}" unless metadata.maintainer_email.blank?
        a.push "     License: #{metadata.license}" unless metadata.license.blank?
        a.push "   Platforms: #{pretty_map(metadata.platforms, 14)}" unless metadata.platforms.blank?
        a.push "Dependencies: #{pretty_map(dependencies, 14)}" unless dependencies.blank?
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
        h[:name]          = cookbook_name unless cookbook_name.blank?
        h[:version]       = version unless version.blank?
        h[:description]   = description unless description.blank?
        h[:author]        = maintainer unless maintainer.blank?
        h[:email]         = maintainer_email unless maintainer_email.blank?
        h[:license]       = license unless license.blank?
        h[:platforms]     = platforms.to_hash unless platforms.blank?
        h[:dependencies]  = dependencies.to_hash unless dependencies.blank?
      end
    end

    def validate
      raise IOError, "No Cookbook found at: #{path}" unless path.exist?

      syntax_checker = Chef::Cookbook::SyntaxCheck.for_cookbook(cookbook_name, path)
      unless syntax_checker.validate_ruby_files
        raise Berkshelf::Errors::CookbookSyntaxError, "Invalid ruby files in cookbook: #{cookbook_name} (#{version})."
      end
      unless syntax_checker.validate_templates
        raise Berkshelf::Errors::CookbookSyntaxError, "Invalid template files in cookbook: #{cookbook_name} (#{version})."
      end

      true
    end

    def compile_metadata
      json_file = "#{path}/metadata.json"
      rb_file = "#{path}/metadata.rb"
      puts "compiling #{rb_file} to #{json_file}"
      return if File.exist?(json_file)
      md = Chef::Cookbook::Metadata.new
      md.from_file(rb_file)
      File.open(json_file, "w") do |f|
        f.write(Chef::JSONCompat.to_json_pretty(md))
      end
    end

    private

    def pretty_map(hash, padding)
      hash.map { |k, v| "#{k} (#{v})" }.join("\n" + " " * padding)
    end
  end
end
