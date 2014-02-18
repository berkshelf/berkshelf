module Berkshelf
  class GitLocation < BaseLocation
    def initialize(dependency, options = {})
      super
      Git.validate_uri!(uri)
    end

    def download
      destination = CookbookStore.instance.storage_path

      if cached?(destination)
        @ref ||= Git.rev_parse(revision_path(destination))
        return local_revision(destination)
      end

      repo_path = Git.clone(uri)

      Git.checkout(repo_path, ref || checkout_info[:rev])
      options[:ref] = Git.rev_parse(repo_path)

      tmp_path = rel ? File.join(repo_path, rel) : repo_path
      unless File.chef_cookbook?(tmp_path)
        msg = "Cookbook '#{dependency.name}' not found at git: #{to_display}"
        msg << " at path '#{rel}'" if rel
        raise CookbookNotFound, msg
      end

      cb_path = revision_path(destination)
      FileUtils.rm_rf(cb_path)
      FileUtils.mv(tmp_path, cb_path)

      super(CachedCookbook.from_store_path(cb_path))
    end

    def uri
      options[:git]
    end

    def branch
      ref || options[:branch] || options[:tag] || 'master'
    end

    def ref
      options[:ref]
    end

    def rel
      options[:rel]
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

    def to_s
      "#{self.class.location_key}: #{to_display}"
    end

    private

    def checkout_info
      if @sha
        kind, rev = "ref", @sha
      else
        kind, rev = "branch", branch
      end

      { kind: kind, rev: rev }
    end

    def to_display
      info = checkout_info
      s = "'#{uri}' with #{info[:kind]}: '#{info[:rev]}'"
      s << " at ref: '#{ref}'" if ref && (info[:kind] != "ref" || ref != info[:rev])
      s
    end

    def cached?(destination)
      revision_path(destination) && File.exists?(revision_path(destination))
    end

    def local_revision(destination)
      path = revision_path(destination)
      cached = CachedCookbook.from_store_path(path)
      validate_cached(cached)
      return cached
    end

    def revision_path(destination)
      return unless ref
      File.join(destination, "#{dependency.name}-#{ref}")
    end
  end
end
