Dir["#{File.dirname(__FILE__)}/monkies/*.rb"].sort.each do |path|
  require "thor/monkies/#{File.basename(path, '.rb')}"
end
