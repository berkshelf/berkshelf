module Berkshelf
  class Config < Hashie::Mash
    DEFAULT_PATH = "~/.berkshelf/config.json"

    include ActiveModel::Validations
    validates_with ConfigValidator

    class << self
      def file
        File.read path if File.exists? path
      end

      def from_json(json)
        hash = JSON.parse(json).to_hash

        new.tap do |config|
          hash.each do |key, value|
            config[key] = value
          end
        end
      end

      def instance
        @instance ||= if file
          from_json file
        else
          new
        end
      end

      def path
        File.expand_path DEFAULT_PATH
      end
    end

    def [](key)
      super or self.class.new
    end
  end
end
