require 'json'

module Berkshelf
  class CachedCookbook < Ridley::Chef::Cookbook
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

        from_path(path, name: cached_name)
      end
    end

    DIRNAME_REGEXP = /^(.+)-(.+)$/

    extend Forwardable
    def_delegators :metadata, :description, :maintainer, :maintainer_email, :license, :platforms

    # @return [Hash]
    def dependencies
      metadata.recommendations.merge(metadata.dependencies)
    end

    # Pretty print this cookbook as a String
    #
    # @return [String]
    def pretty_print
      [
        "        Name: #{cookbook_name}",
        "     Version: #{version}",
        " Description: #{description}",
        "      Author: #{maintainer}",
        "       Email: #{maintainer_email}",
        "     License: #{license}",
        "   Platforms: #{pretty_map(platforms, 14)}",
        "Dependencies: #{pretty_map(dependencies, 14)}",
      ].reject do |item|
        contents = item.split(':', 2).last.strip
        contents.nil? || contents.empty?
      end.join("\n")
    end

    # The pretty formatted JSON of this cookbook.
    #
    # @return [String]
    def pretty_json
      JSON.pretty_generate(pretty_hash)
    end

    # The hash of this cookbook.
    #
    # @return [Hash]
    def pretty_hash
      {
        name:         cookbook_name,
        version:      version,
        description:  description,
        author:       maintainer,
        email:        maintainer_email,
        license:      license,
        platforms:    hash_or_nil(platforms),
        dependencies: hash_or_nil(dependencies),
      }.reject do |key, value|
        value.nil? ||
        value.empty? || (value.respond_to?(:strip) && value.strip.empty?)
      end
    end

    private
      # Map dependencies with appropriate spacing.
      #
      # @return [String]
      def pretty_map(hash, padding)
        return hash unless hash.is_a?(Hash)
        hash.map { |k,v| "#{k} (#{v})" }.join("\n" + ' '*padding)
      end

      # Convert the given object to a hash, or return nil.
      #
      # @return [Hash, nil]
      def hash_or_nil(obj)
        return nil if obj.nil?
        return obj if obj.is_a?(Hash)
        obj.respond_to?(:to_hash) ? obj.to_hash : nil
      end
  end
end
