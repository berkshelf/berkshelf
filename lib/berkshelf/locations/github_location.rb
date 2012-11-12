module Berkshelf
  # @author Josiah Kiehl <josiah@skirmisher.net>
  class GithubLocation < GitLocation
    DEFAULT_PROTOCOL = 'git'

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
    def initialize(name, version_constraint, options = {})
      @repo_identifier = options.delete(:github)
      @protocol = options.delete(:protocol) || DEFAULT_PROTOCOL
      options[:git] = github_url
      super
    end

    def github_url
      case protocol.to_s
      when 'ssh'
        "git@github.com:#{repo_identifier}.git"
      when 'https'
        "https://github.com/#{repo_identifier}.git"
      when 'git'
        "git://github.com/#{repo_identifier}.git"
      else
        raise UnknownGitHubProtocol.new(protocol)
      end
    end

    def to_s
      s = "#{self.class.location_key}: '#{repo_identifier}'"
      s << " with branch: '#{branch}'"     if branch
      s << " over protocol: '#{protocol}'" unless default_protocol?
      s
    end

    private

      def default_protocol?
        @protocol == DEFAULT_PROTOCOL
      end
  end
end
