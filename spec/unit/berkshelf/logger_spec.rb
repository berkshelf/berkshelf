require 'spec_helper'

describe Berkshelf::Logger do
  # Berkshelf::Logger#info
  context '#info' do
    it 'responds' do
      expect(Berkshelf::Logger).to respond_to(:info)
    end
  end

  # Berkshelf::Logger#warn
  context '#warn' do
    it 'responds' do
      expect(Berkshelf::Logger).to respond_to(:warn)
    end
  end

  # Berkshelf::Logger#error
  context '#error' do
    it 'responds' do
      expect(Berkshelf::Logger).to respond_to(:error)
    end
  end

  # Berkshelf::Logger#fatal
  context '#fatal' do
    it 'responds' do
      expect(Berkshelf::Logger).to respond_to(:fatal)
    end
  end

  # Berkshelf::Logger#debug
  context '#debug' do
    it 'responds' do
      expect(Berkshelf::Logger).to respond_to(:debug)
    end
  end

  # Berkshelf::Logger#deprecate
  context '#deprecate' do
    it 'responds' do
      expect(Berkshelf::Logger).to respond_to(:deprecate)
    end
  end
end
