module Berkshelf
  # @author Jamie Winsor <reset@riotgames.com>
  module Mixin; end
end

Dir["#{File.dirname(__FILE__)}/mixin/*.rb"].sort.each do |path|
  require "berkshelf/mixin/#{File.basename(path, '.rb')}"
end
