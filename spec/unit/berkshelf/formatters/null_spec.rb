require 'spec_helper'

describe Berkshelf::Formatters::NullFormatter do
  context 'an abstract method' do
    it 'does not raise an error' do
      expect { subject.version }.to_not raise_error
    end
  end

  context 'an undefined method' do
    it 'raises a NoMethodError' do
      expect { subject.bacon }.to raise_error
    end
  end
end
