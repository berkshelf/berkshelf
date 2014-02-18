module Berkshelf
  class GithubLocation < GitLocation
    def initialize(dependency, options = {})
      options[:git] = "https://github.com/#{options.delete(:github)}.git"
      super
    end
  end
end
