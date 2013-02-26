require 'berkshelf/chef'

module Berkshelf::Mixin
  # @author Jamie Winsor <reset@riotgames.com>
  #
  # Inspired by and dependency-free replacement for
  # {https://github.com/opscode/chef/blob/11.4.0/lib/chef/mixin/checksum.rb}
  module Checksum
    # @param [String] file
    #
    # @return [String]
    def checksum(file)
      Berkshelf::Chef::Digester.checksum_for_file(file)
    end
  end
end
