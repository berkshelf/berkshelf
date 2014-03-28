require 'spec_helper'

describe Berkshelf::Mixin::Logging do
  subject do
    Class.new { include Berkshelf::Mixin::Logging }.new
  end

  describe '#logger' do
    it 'returns the Berkshelf::Logger' do
      expect(subject.logger).to be_a(Berkshelf::Logger)
    end
  end

  describe '#log' do
    it 'returns the Berkshelf::Logger' do
      expect(subject.log).to be_a(Berkshelf::Logger)
    end
  end
end
