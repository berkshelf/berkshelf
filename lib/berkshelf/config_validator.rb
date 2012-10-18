module Berkshelf
  class ConfigValidator < ActiveModel::Validator
    DEFAULT_STRUCTURE = {
      vagrant: {
        vm: {
          forward_port: Hash
        },
        network: {
          bridged: Object,
          hostonly: String
        }
      }
    }

    def assert_in_structure(actual_hash, expected_hash)
      actual_hash.keys.each do |key|
        return unless expected_hash.keys.include? key.to_sym

        actual = actual_hash[key]
        expected = expected_hash[key.to_sym]

        if actual.is_a?(Hash) && expected.is_a?(Hash)
          return unless assert_in_structure actual, expected
        else
          return unless actual.is_a? expected
        end
      end

      true
    end

    def structure
      @structure ||= DEFAULT_STRUCTURE
    end

    def validate(config)
      assert_in_structure config, structure
    end
  end
end

