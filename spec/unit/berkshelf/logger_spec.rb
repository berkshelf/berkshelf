require 'spec_helper'

describe Berkshelf::Logger do
  # Berkshelf::Logger#info
  describe '#info' do
    it 'responds' do
      expect(Berkshelf::Logger).to respond_to(:info)
    end
  end

  # Berkshelf::Logger#warn
  describe '#warn' do
    it 'responds' do
      expect(Berkshelf::Logger).to respond_to(:warn)
    end
  end

  # Berkshelf::Logger#error
  describe '#error' do
    it 'responds' do
      expect(Berkshelf::Logger).to respond_to(:error)
    end
  end

  # Berkshelf::Logger#fatal
  describe '#fatal' do
    it 'responds' do
      expect(Berkshelf::Logger).to respond_to(:fatal)
    end
  end

  # Berkshelf::Logger#debug
  describe '#debug' do
    it 'responds' do
      expect(Berkshelf::Logger).to respond_to(:debug)
    end
  end

  # Berkshelf::Logger#deprecate
  describe '#deprecate' do
    it 'responds' do
      expect(Berkshelf::Logger).to respond_to(:deprecate)
    end
  end
end
