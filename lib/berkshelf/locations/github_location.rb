module Berkshelf
  # @author Josiah Kiehl <josiah@skirmisher.net>
  class GithubLocation < GitLocation
    set_location_key :github

    # Wraps GitLocation allowing the short form GitHub repo identifier
    # to be used in place of the complete repo url.
    # 
    # @see GitLocation#initialize for parameter documentation
    #
    # @option options [String] :github
    #   the GitHub repo identifier to clone
    def initialize(name, version_constraint, options = {})
      @repo_identifier = options.delete(:github)
      options[:git] = github_url(@repo_identifier)
      super
    end

    def github_url(repo_identifier)
      "git://github.com/#{repo_identifier}.git"
    end

    def to_s
      s = "#{self.class.location_key}: '#{@repo_identifier}'"
      s << " with branch: '#{branch}'" if branch
      s
    end
  end
end
