module Berkshelf
  module Mixin; end
end

Dir["#{File.dirname(__FILE__)}/mixin/*.rb"].sort.each do |path|
  require_relative "mixin/#{File.basename(path, '.rb')}"
end
