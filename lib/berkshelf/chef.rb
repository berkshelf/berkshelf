module Berkshelf
  # @author Jamie Winsor <reset@riotgames.com>
  #
  # Classes and modules used for integrating with a Chef Server, the Chef community
  # site, and Chef Cookbooks
  module Chef
    require_relative 'chef/config'
    require_relative 'chef/cookbook'
  end
end
