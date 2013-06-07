module Berkshelf
  Logger = Celluloid::Logger.dup

  Logger.module_eval do
    def self.fatal(string)
      error(string)
    end
  end
end
