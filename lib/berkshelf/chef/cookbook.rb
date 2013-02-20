module Berkshelf::Chef
  # @author Jamie Winsor <reset@riotgames.com>
  module Cookbook
    autoload :Chefignore, 'berkshelf/chef/cookbook/chefignore'
    autoload :Metadata, 'berkshelf/chef/cookbook/metadata'
    autoload :SyntaxCheck, 'berkshelf/chef/cookbook/syntax_check'
  end
end
