module Berkshelf
  # @author Jamie Winsor <reset@riotgames.com>
  #
  # Classes and modules used for integrating with a Chef Server, the Chef community
  # site, and Chef Cookbooks
  module Chef
    autoload :Config, 'berkshelf/chef/config'
    autoload :Chefignore, 'berkshelf/chef/chefignore'
    autoload :Digester, 'berkshelf/chef/digester'
  end
end
