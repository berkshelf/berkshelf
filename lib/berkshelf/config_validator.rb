module Berkshelf
  # @author Justin Campbell <justin@justincampbell.me>
  class ConfigValidator < ActiveModel::Validator
    DEFAULT_STRUCTURE = {
      vagrant: {
        chef: {
          chef_server_url: String,
          validation_client_name: String,
          validation_key_path: String
        },
        vm: {
          box: String,
          box_url: String,
          forward_port: Hash,
          host_name: String,
          network: {
            bridged: Object,
            hostonly: String
          },
          provision: String
        }
      }
    }

    # Recursively validate the structure of a hash with another hash. If
    # invalid, the actual_hash will have errors added to it.
    #
    # @param [Hash] actual_hash
    #   The hash to validate
    #
    # @param [Hash] expected_hash
    #   The expected structure of actual_hash
    #
    # @param [Config] config
    #   The config object to add errors to. This is only used recursively.
    #
    # @return [Boolean]
    def assert_in_structure(actual_hash, expected_hash, config = nil)
      config ||= actual_hash

      actual_hash.keys.each do |key|
        unless expected_hash.keys.include? key.to_sym
          config.errors.add key, "is not a valid key"
          return
        end

        actual = actual_hash[key]
        expected = expected_hash[key.to_sym]

        if actual.is_a?(Hash) && expected.is_a?(Hash)
          return unless assert_in_structure actual, expected, config
        else
          unless actual.is_a? expected
            config.errors.add key, "should be an instance of #{expected}"
            return
          end
        end
      end

      true
    end

    # @see DEFAULT_STRUCTURE
    # @return [Hash]
    def structure
      @structure ||= DEFAULT_STRUCTURE
    end

    # @param [Config] config
    #   The config to validate
    #
    # @return [Boolean]
    def validate(config)
      assert_in_structure config, structure
    end
  end
end

