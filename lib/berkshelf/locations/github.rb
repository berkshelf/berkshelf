module Berkshelf
  class GithubLocation < GitLocation
    HOST = 'github.com'
    def initialize(dependency, options = {})
      transport = Berkshelf::Config.instance.github.transport || 'git'
      case transport.downcase
      when 'ssh'
        options[:git] = "git@#{HOST}:#{options.delete(:github)}.git"
      when 'https'
        options[:git] = "https://#{HOST}/#{options.delete(:github)}.git"
      else
        options[:git] = "git://#{HOST}/#{options.delete(:github)}.git"
      end
      super
    end
  end
end
