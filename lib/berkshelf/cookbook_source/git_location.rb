module Berkshelf
  class CookbookSource
    # @author Jamie Winsor <jamie@vialstudios.com>
    class GitLocation
      include Location

      attr_accessor :uri
      attr_accessor :branch

      alias_method :ref, :branch
      alias_method :tag, :branch

      # @param [#to_s] name
      # @param [DepSelector::VersionConstraint] version_constraint
      # @param [Hash] options
      def initialize(name, version_constraint, options)
        @name = name
        @version_constraint = version_constraint
        @uri = options[:git]
        @branch = options[:branch] || options[:ref] || options[:tag]

        Git.validate_uri!(@uri)
      end

      # @param [#to_s] destination
      #
      # @return [String]
      #   path to the downloaded source
      def download(destination)
        tmp_clone = Dir.mktmpdir
        ::Berkshelf::Git.clone(uri, tmp_clone)
        ::Berkshelf::Git.checkout(tmp_clone, branch) if branch
        unless branch
          self.branch = ::Berkshelf::Git.rev_parse(tmp_clone)
        end

        unless File.chef_cookbook?(tmp_clone)
          msg = "Cookbook '#{name}' not found at git: #{uri}" 
          msg << " with branch '#{branch}'" if branch
          raise CookbookNotFound, msg
        end

        cb_path = File.join(destination, "#{self.name}-#{self.branch}")
        FileUtils.mv(tmp_clone, cb_path, force: true)
        
        validate_downloaded!(cb_path)
        
        set_downloaded_status(true)
        CachedCookbook.from_store_path(cb_path)
      rescue Berkshelf::GitError
        raise CookbookNotFound, "Cookbook '#{name}' not found at #{self}" 
      end

      def to_s
        s = "git: '#{uri}'"
        s << " with branch: '#{branch}'" if branch
        s
      end

      private

        def git
          @git ||= Berkshelf::Git.new(uri)
        end
    end
  end
end
