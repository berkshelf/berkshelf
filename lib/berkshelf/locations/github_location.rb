module Berkshelf
  # @author Jamie Winsor <jamie@vialstudios.com>
  class GithubLocation < GitLocation
    include Location

    set_location_key :github

    # @param [#to_s] name
    # @param [Solve::Constraint] version_constraint
    # @param [Hash] options
    #
    # @option options [String] :github
    #   the GitHub repo identifier to clone
    # @option options [String] :ref
    #   the commit hash or an alias to a commit hash to clone
    # @option options [String] :branch
    #   same as ref
    # @option options [String] :tag
    #   same as tag
    def initialize(name, version_constraint, options = {})
      options[:git] = github_url(options.delete(:github))
      super
    end

    def github_url(repo_identifier)
      "git://github.com/#{repo_identifier}.git"
    end
  end
end
