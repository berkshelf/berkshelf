module Berkshelf
  class SubversionLocation < Location::ScmLocation

    set_location_key :svn
    set_valid_options :rev

    attr_accessor :uri
    attr_accessor :rev
    attr_reader :options

    # @param [Dependency] dependency
    # @param [Hash] options
    #
    # @option options [String] :svn
    #   the Subversion URL to checkout
    # @option options [String] :rev
    #   the revision to checkout
    def initialize(dependency, options = {})
      super
      @uri    = options[:svn]
      @rev    = options[:rev] || 'HEAD'

      Subversion.validate_uri!(@uri)
    end

    # @param [#to_s] destination
    #
    # @return [Berkshelf::CachedCookbook]
    def do_download
      destination = Berkshelf::CookbookStore.instance.storage_path

      if cached?(destination)
        @rev ||= Berkshelf::Subversion.rev_parse(revision_path(destination))
        return local_revision(destination)
      end

      Berkshelf::Subversion.checkout(uri, working_copy, rev) if rev
      @rev = Berkshelf::Subversion.rev_parse(working_copy)

      unless File.chef_cookbook?(working_copy)
        msg = "Cookbook '#{dependency.name}' not found at svn: #{uri}"
        msg << " with rev '#{rev}'" if rev
        raise CookbookNotFound, msg
      end

      cb_path = revision_path(destination)
      FileUtils.rm_rf(cb_path)
      FileUtils.mv(working_copy, cb_path)

      cached = CachedCookbook.from_store_path(cb_path)
      validate_cached(cached)

      cached
    end

    def to_hash
      super.tap do |h|
        h[:value]  = self.uri
      end
    end

    def to_s
      s = "#{self.class.location_key}: '#{uri}'"
      s << " at rev: '#{rev}'" if rev
      s
    end

    private

      def svn
        @svn ||= Berkshelf::Subversion.new(uri)
      end

      def working_copy
        tmp_working_copy = File.join(self.class.tmpdir, uri.gsub(/[\/:]/,'-'))

        unless File.exists?(tmp_working_copy)
          Berkshelf::Subversion.checkout(uri, tmp_working_copy, rev)
        end

        tmp_working_copy
      end

      def cached?(destination)
        revision_path(destination) && File.exists?(revision_path(destination))
      end

      def local_revision(destination)
        path = revision_path(destination)
        cached = Berkshelf::CachedCookbook.from_store_path(path)
        validate_cached(cached)
        return cached
      end

      def revision_path(destination)
        return unless rev
        File.join(destination, "#{dependency.name}-#{rev}")
      end
  end
end
