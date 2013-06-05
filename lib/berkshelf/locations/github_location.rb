module Berkshelf
  class GithubLocation < GitLocation
    DEFAULT_PROTOCOL = :git

    set_location_key :github
    set_valid_options :protocol

    attr_accessor :protocol
    attr_accessor :repo_identifier

    # Wraps GitLocation allowing the short form GitHub repo identifier
    # to be used in place of the complete repo url.
    #
    # @see GitLocation#initialize for parameter documentation
    #
    # @option options [String] :github
    #   the GitHub repo identifier to clone
    # @option options [#to_sym] :protocol
    #   the protocol with which to communicate with GitHub
    def initialize(name, version_constraint, options = {})
      @repo_identifier = options.delete(:github)
      @protocol        = (options.delete(:protocol) || DEFAULT_PROTOCOL).to_sym
      options[:git]    = github_url
      super
    end

    # Returns the appropriate GitHub url given the specified protocol
    #
    # @raise [UnknownGitHubProtocol] if the specified protocol is not supported.
    #
    # @return [String]
    #   GitHub url
    def github_url
      case protocol
      when :ssh
        "git@github.com:#{repo_identifier}.git"
      when :https
        "https://github.com/#{repo_identifier}.git"
      when :git
        "git://github.com/#{repo_identifier}.git"
      else
        raise UnknownGitHubProtocol.new(protocol)
      end
    end

    def to_s
      s = "#{self.class.location_key}: '#{repo_identifier}'"
      s << " with branch: '#{branch}'" if branch
      s << " over protocol: '#{protocol}'"
      s
    end

    private

      def default_protocol?
        self.protocol == DEFAULT_PROTOCOL
      end
  end
end
