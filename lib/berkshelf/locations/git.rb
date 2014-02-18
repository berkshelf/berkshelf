module Berkshelf
  class GitLocation < BaseLocation
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

      Git.validate_uri!(uri)
    end

    def download
      if cached?
        @revision ||= Git.rev_parse(revision_path)
      else
        repo_path = Git.clone(uri)

        Git.checkout(repo_path, ref)
        @revision = Git.rev_parse(repo_path)

        tmp_path = rel ? File.join(repo_path, rel) : repo_path
        unless File.chef_cookbook?(tmp_path)
          raise CookbookNotFound,
            "Cookbook '#{dependency.name}' not found at #{to_s}"
        end

        FileUtils.rm_rf(revision_path)
        FileUtils.mv(tmp_path, revision_path)
      end

      cookbook = CachedCookbook.from_store_path(revision_path)
      super(cookbook)
    end

    def scm_location?
      true
    end

    def to_hash
      super.tap do |h|
        h[:value]  = self.uri
        h[:branch] = self.branch if branch
      end
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

    def cached?
      revision && File.exists?(revision_path)
    end

    def revision_path
      cache_path.join("#{dependency.name}-#{revision}").to_s
    end

    def cache_path
      Berkshelf.cookbook_store.storage_path
    end
  end
end
