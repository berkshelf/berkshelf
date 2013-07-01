Dir["#{File.dirname(__FILE__)}/thor_ext/*.rb"].sort.each do |path|
  require_relative "thor_ext/#{File.basename(path, '.rb')}"
end
