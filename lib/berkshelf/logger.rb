module Berkshelf
  Logger = Celluloid::Logger

  Logger.module_eval do
    def self.fatal(string)
      error(string)
    end
  end
end
