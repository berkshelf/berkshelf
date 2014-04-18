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

        loaded_cookbooks[path.to_s] ||= from_path(path)
      end

      private

        # @return [Hash<String, CachedCookbook>]
        def loaded_cookbooks
          @loaded_cookbooks ||= {}
        end
    end

    DIRNAME_REGEXP = /^(.+)-(.+)$/.freeze

    extend Forwardable
    def_delegator :metadata, :description
    def_delegator :metadata, :maintainer
    def_delegator :metadata, :maintainer_email
    def_delegator :metadata, :license
    def_delegator :metadata, :platforms

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

    private

      def pretty_map(hash, padding)
        hash.map { |k,v| "#{k} (#{v})" }.join("\n" + ' '*padding)
      end
  end
end
