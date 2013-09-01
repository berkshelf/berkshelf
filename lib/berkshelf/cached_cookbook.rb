module Berkshelf
  class CachedCookbook < Ridley::Chef::Cookbook
    @loaded = Hash.new

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

        @loaded[path.to_s] ||= from_path(path, name: cached_name)
      end
    end

    DIRNAME_REGEXP = /^(.+)-(.+)$/

    # @return [Hash]
    def dependencies
      metadata.recommendations.merge(metadata.dependencies)
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

    def pretty_json
      pretty_hash.to_json
    end

    def pretty_hash
      {}.tap do |h|
        h[:name]          = cookbook_name unless name.blank?
        h[:version]       = version unless version.blank?
        h[:description]   = metadata.description unless metadata.description.blank?
        h[:author]        = metadata.maintainer unless metadata.maintainer.blank?
        h[:email]         = metadata.maintainer_email unless metadata.maintainer_email.blank?
        h[:license]       = metadata.license unless metadata.license.blank?
        h[:platforms]     = metadata.platforms.to_hash unless metadata.platforms.blank?
        h[:dependencies]  = dependencies.to_hash unless dependencies.blank?
      end
    end

    private

      def pretty_map(hash, padding)
        hash.map { |k,v| "#{k} (#{v})" }.join("\n" + ' '*padding)
      end
  end
end
