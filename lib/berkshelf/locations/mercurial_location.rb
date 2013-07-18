module Berkshelf
  class MercurialLocation < Location::ScmLocation

    set_location_key :hg
    set_valid_options :rev, :branch, :tag, :rel

    attr_accessor :uri
    attr_accessor :rel
    attr_accessor :rev
    attr_reader :options

    alias_method :tag, :rev
    alias_method :branch, :rev

    # @param [Dependency] dependency
    # @param [Hash] options
    #
    # @option options [String] :hg
    #   the URL to clone
    # @option options [String] :rev
    #   the revision to checkout
    # @option options [String] :branch
    #   same as rev
    # @option options [String] :tag
    #   same as rev
    # @option options [String] :rel
    #   the path within the repository to find the cookbook
    def initialize(dependency, options = {})
      super
      @uri = options[:hg]
      @rev = options[:rev] || options[:branch] || options[:tag] || 'default'
      @rel = options[:rel]

      Mercurial.validate_uri!(@uri)
    end

    # @return [Berkshelf::CachedCookbook]
    def do_download
      destination = Berkshelf::CookbookStore.instance.storage_path

      if cached?(destination)
        @rev ||= Berkshelf::Mercurial.rev_parse(revision_path(destination))
        return local_revision(destination)
      end

      Berkshelf::Mercurial.checkout(clone, rev || branch || tag) if rev || branch || tag
      @rev = Berkshelf::Mercurial.rev_parse(clone)

      tmp_path = rel ? File.join(clone, rel) : clone
      unless File.chef_cookbook?(tmp_path)
        msg = "Cookbook '#{dependency.name}' not found at hg: #{uri}"
        msg << " with rev '#{rev}'" if rev
        msg << " at path '#{rel}'" if rel
        raise CookbookNotFound, msg
      end

      cb_path = revision_path(destination)
      FileUtils.rm_rf(cb_path)
      FileUtils.mv(tmp_path, cb_path)

      cached = CachedCookbook.from_store_path(cb_path)
      validate_cached(cached)

      cached
    end

    def to_hash
      super.tap do |h|
        h[:value]  = self.uri
        h[:branch] = self.branch if branch
      end
    end

    def to_s
      s = "#{self.class.location_key}: '#{uri}'"
      s << " at rev: '#{rev}'" if rev
      s
    end

    private

      def hg
        @hg ||= Berkshelf::Mercurial.new(uri)
      end

      def clone
        tmp_clone = File.join(self.class.tmpdir, uri.gsub(/[\/:]/,'-'))
        FileUtils.mkdir_p(File.join(File.split(tmp_clone).shift))
        unless File.exists?(tmp_clone)
          Berkshelf::Mercurial.clone(uri, tmp_clone)
        end

        tmp_clone
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
