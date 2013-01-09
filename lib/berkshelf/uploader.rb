require 'chef/cookbook_uploader'

module Berkshelf
  # @author Jamie Winsor <jamie@vialstudios.com>
  class Uploader
    extend Forwardable

    # Uploads a CachedCookbook from a CookbookStore to this instances Chef Server URL
    #
    # @param [CachedCookbook] cookbook
    #   a cached cookbook to upload
    #
    # @option options [Boolean] :force
    #   Upload the Cookbook even if the version already exists and is frozen on
    #   the target Chef Server
    # @option options [Boolean] :freeze
    #   Freeze the uploaded Cookbook on the Chef Server so that it cannot be
    #   overwritten
    # @option options [Boolean] :skip_syntax_check
    #   Skip syntax checking of the Cookbook to reduce the overall upload time 
    #
    # @raise [CookbookNotFound]
    # @raise [CookbookSyntaxError]
    #
    # @return [Boolean]
    def upload(cookbook, options = {})
      cookbook.validate! unless options[:skip_syntax_check]
      loader = Chef::Cookbook::CookbookVersionLoader.new(cookbook.path)
      loader.load_cookbooks
      cv = loader.cookbook_version
      cv.send(:generate_manifest)
      cv.name = cookbook.cookbook_name.to_sym
      cv.manifest['name'] = "#{cookbook.cookbook_name}-#{cookbook.version}" #.sub!(%r{-[^-]+$}, '')
      cv.manifest['cookbook_name'] = cookbook.cookbook_name
      cv.freeze_version if options.delete(:freeze)
      Chef::CookbookUploader.new([cv], cookbook.path, options).upload_cookbooks
    end
  end
end
