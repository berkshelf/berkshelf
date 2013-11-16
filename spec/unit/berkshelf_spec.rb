require 'spec_helper'

describe Berkshelf do
  describe '.formatter' do
    context 'with default formatter' do
      it 'should be human readable' do
        Berkshelf.remove_instance_variable(:@formatter)
        expect(Berkshelf.formatter).to be_a(Berkshelf::Formatters::HumanFormatter)
      end
    end
  end

  describe '.log' do
    it 'returns Berkshelf::Logger' do
      expect(Berkshelf.log).to eq(Berkshelf::Logger)
    end
  end
end
