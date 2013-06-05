module Berkshelf
  # Because aruba runs in a sub-process, there's no easy way to share mocks and
  # stubs across a run (See RiotGames/berkshelf#208). As a work-around, we pass
  # "special" mocks and stubs into the TEST environment variable. This class
  # parses and then requires the appropriate mocks during the run.
  class Mocks
    require 'rspec/mocks/standalone'

    class << self
      def env_keys
        self.instance_methods(false).map { |key| key.to_s.upcase }
      end
    end

    def initialize(keys)
      keys.each do |key|
        self.send(key.downcase.to_sym, ENV[key.to_s])
      end
    end

    # Trick bundler into thinking gems are missing.
    #
    # @param [String] gems
    #   a CSV list of gems to be missing
    def missing_gems(gems)
      gems.split(',').each do |gem|
        Gem::Specification.stub(:find_by_name).with(gem).and_raise(Gem::LoadError)
      end
    end
  end
end

unless (keys = Berkshelf::Mocks.env_keys & ENV.keys).empty?
  Berkshelf::Mocks.new(keys)
end
