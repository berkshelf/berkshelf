Dir["#{File.dirname(__FILE__)}/core_ext/*.rb"].sort.each do |path|
  require_relative "core_ext/#{File.basename(path, '.rb')}"
end
