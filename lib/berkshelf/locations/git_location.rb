module Berkshelf
  class GitLocation < Location::ScmLocation
    set_location_key :git
    set_valid_options :ref, :branch, :tag, :rel

    attr_accessor :uri
    attr_accessor :branch
    attr_accessor :rel
    attr_accessor :ref
    attr_reader :options

    alias_method :tag, :branch

    # @param [Dependency] dependency
    # @param [Hash] options
    #
    # @option options [String] :git
    #   the Git URL to clone
    # @option options [String] :ref
    #   the commit hash or an alias to a commit hash to clone
    # @option options [String] :branch
    #   same as ref
    # @option options [String] :tag
    #   same as tag
    # @option options [String] :rel
    #   the path within the repository to find the cookbook
    def initialize(dependency, options = {})
      super
      @uri    = options[:git]
      @ref    = options[:ref]
      @branch = options[:branch] || options[:tag] || "master" unless ref
      @sha    = ref
      @rel    = options[:rel]

      Git.validate_uri!(@uri)
    end

    # @example
    #     irb> location.checkout_info
    #     { kind: "branch", rev: "master" }
    #
    # @return [Hash]
    def checkout_info
      if @sha
        kind, rev = "ref", @sha
      else
        kind, rev = "branch", branch
      end

      { kind: kind, rev: rev }
    end

    # @param [#to_s] destination
    #
    # @return [Berkshelf::CachedCookbook]
    def do_download
      destination = Berkshelf::CookbookStore.instance.storage_path

      if cached?(destination)
        @ref ||= Berkshelf::Git.rev_parse(revision_path(destination))
        return local_revision(destination)
      end

      repo_path = Berkshelf::Git.clone(uri)

      Berkshelf::Git.checkout(repo_path, ref || checkout_info[:rev])
      @ref = Berkshelf::Git.rev_parse(repo_path)

      tmp_path = rel ? File.join(repo_path, rel) : repo_path
      unless File.chef_cookbook?(tmp_path)
        msg = "Cookbook '#{dependency.name}' not found at #{to_s}"
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
      if rel
        "#{uri} (at #{branch || ref[0...7]}/#{rel})"
      else
        "#{uri} (at #{branch || ref[0...7]})"
      end
    end

    private

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
        return unless ref
        File.join(destination, "#{dependency.name}-#{ref}")
      end
  end
end
