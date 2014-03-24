module Berkshelf
  class GithubLocation < GitLocation
    def initialize(dependency, options = {})
      uri = URI.parse("git://github.com/#{options.delete(:github)}.git")

      uri.userinfo = 'git' if options[:protocol] == :ssh
      uri.scheme   = (options[:protocol] || 'git').to_s

      options[:git] = uri.to_s

      super
    end
  end
end
