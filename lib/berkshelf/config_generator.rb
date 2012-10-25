module Berkshelf
  # @author Justin Campbell <justin@justincampbell.me>
  class ConfigGenerator < BaseGenerator
    def generate
      template "config.json", Config.path
    end
  end
end
