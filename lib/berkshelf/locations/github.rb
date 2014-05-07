module Berkshelf
  class GithubLocation < GitLocation
    def initialize(dependency, options = {})
      if options[:protocol] == :ssh
        uri = 'git@github.com:%{github}.git'
      else
        uri = 'git://github.com/%{github}.git'
      end
      options[:git] = uri % {:github => options.delete(:github)}
      super
    end
  end
end
