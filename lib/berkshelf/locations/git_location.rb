module Berkshelf
  # @author Jamie Winsor <reset@riotgames.com>
  class GitLocation
    class << self
      # Create a temporary directory for the cloned repository within Berkshelf's
      # temporary directory
      #
      # @return [String]
      #   the path to the created temporary directory
      def tmpdir
        @tmpdir ||= Dir.mktmpdir(Berkshelf.mktmpdir)
      end
    end

    include Location

    set_location_key :git
    set_valid_options :ref, :branch, :tag, :rel

    attr_accessor :uri
    attr_accessor :branch
    attr_accessor :rel

    alias_method :ref, :branch
    alias_method :tag, :branch

    # @param [#to_s] name
    # @param [Solve::Constraint] version_constraint
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
    def initialize(name, version_constraint, options = {})
      @name               = name
      @version_constraint = version_constraint
      @uri                = options[:git]
      @branch             = options[:branch] || options[:ref] || options[:tag]
      @rel                = options[:rel]

      Git.validate_uri!(@uri)
    end

    # @param [#to_s] destination
    #
    # @return [Berkshelf::CachedCookbook]
    def download(destination)
      ::Berkshelf::Git.checkout(clone, branch) if branch
      unless branch
        self.branch = ::Berkshelf::Git.rev_parse(clone)
      end

      tmp_path = rel ? File.join(clone, rel) : clone
      unless File.chef_cookbook?(tmp_path)
        msg = "Cookbook '#{name}' not found at git: #{uri}"
        msg << " with branch '#{branch}'" if branch
        msg << " at path '#{rel}'" if rel
        raise CookbookNotFound, msg
      end

      cb_path = File.join(destination, "#{self.name}-#{Git.rev_parse(clone)}")
      FileUtils.rm_rf(cb_path)
      FileUtils.mv(tmp_path, cb_path)

      cached = CachedCookbook.from_store_path(cb_path)
      validate_cached(cached)

      set_downloaded_status(true)
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
      s << " with branch: '#{branch}'" if branch
      s
    end

    private

      def git
        @git ||= Berkshelf::Git.new(uri)
      end

      def clone
        tmp_clone = File.join(self.class.tmpdir, uri.gsub(/[\/:]/,'-'))

        unless File.exists?(tmp_clone)
          Berkshelf::Git.clone(uri, tmp_clone)
        end

        tmp_clone
      end
  end
end
