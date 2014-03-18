module Berkshelf
  class GitLocation < Location::ScmLocation
    set_location_key :git
    set_valid_options :ref, :branch, :tag, :revision, :rel

    attr_reader :uri
    attr_reader :branch
    attr_reader :tag
    attr_reader :ref
    attr_reader :revision
    attr_reader :rel

    def initialize(dependency, options = {})
      super

      @uri      = options[:git]
      @branch   = options[:branch]
      @tag      = options[:tag]
      @ref      = options[:ref] || options[:branch] || options[:tag] || 'master'
      @revision = options[:revision]
      @rel      = options[:rel]

      Git.validate_uri!(@uri)
    end

    # @param [#to_s] destination
    #
    # @return [Berkshelf::CachedCookbook]
    def do_download
      destination = Berkshelf::CookbookStore.instance.storage_path

      if cached?(destination)
        @revision ||= Berkshelf::Git.rev_parse(revision_path(destination))
        return local_revision(destination)
      end

      repo_path = Berkshelf::Git.clone(uri)

      Berkshelf::Git.checkout(repo_path, ref)
      @revision = Berkshelf::Git.rev_parse(repo_path)

      tmp_path = rel ? File.join(repo_path, rel) : repo_path
      unless File.chef_cookbook?(tmp_path)
        name    = dependency.name
        version = dependency.locked_version || dependency.version_constraint
        raise CookbookNotFound.new(name, version, "at #{to_s}")
      end

      cb_path = revision_path(destination)
      FileUtils.rm_rf(cb_path)
      FileUtils.mv(tmp_path, cb_path)

      cached = CachedCookbook.from_store_path(cb_path)
      validate_cached(cached)

      cached
    end

    def ==(other)
      other.is_a?(GitLocation) &&
      other.uri == uri &&
      other.branch == branch &&
      other.tag == tag &&
      other.ref == ref &&
      other.rel == rel
    end

    def to_s
      info = tag || branch || ref[0...7]

      if rel
        "#{uri} (at #{info}/#{rel})"
      else
        "#{uri} (at #{info})"
      end
    end

    def to_lock
      out =  "    git: #{uri}\n"
      out << "    revision: #{revision}\n"
      out << "    branch: #{branch}\n" if branch
      out << "    tag: #{tag}\n"       if tag
      out << "    rel: #{rel}\n"       if rel
      out
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
        return unless revision
        File.join(destination, "#{dependency.name}-#{revision}")
      end
  end
end
