module Berkshelf
  # @author Justin Campbell <justin@justincampbell.me>
  class Config < Hashie::Mash
    DEFAULT_PATH = "~/.berkshelf/config.json"

    include ActiveModel::Validations
    validates_with ConfigValidator

    class << self
      # @return [String, nil]
      #   the contents of the file
      def file
        File.read path if File.exists? path
      end

      # @param [#to_s] json
      #
      # @return [Config]
      def from_json(json)
        hash = JSON.parse(json).to_hash

        new.tap do |config|
          hash.each do |key, value|
            config[key] = value
          end
        end
      end

      # @return [Config]
      def instance
        @instance ||= if file
          from_json file
        else
          new
        end
      end

      # @return [String]
      def path
        File.expand_path DEFAULT_PATH
      end
    end

    # @param [String, Symbol] key
    #
    # @return [Config, Object]
    def [](key)
      super or self.class.new
    end
  end
end
