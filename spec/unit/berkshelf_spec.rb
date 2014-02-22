require 'spec_helper'

module Berkshelf
  describe '.formatter' do
    context 'with default formatter' do
      before { Berkshelf.instance_variable_set(:@formatter, nil) }

      it 'is human readable' do
        expect(Berkshelf.formatter).to be_an_instance_of(HumanFormatter)
      end
    end

    context 'with a custom formatter' do
      before(:all) do
        Berkshelf.instance_eval { @formatter = nil }
      end

      class CustomFormatter < BaseFormatter; end

      before do
        Berkshelf.set_format :custom
      end

      it 'is custom class' do
        expect(Berkshelf.formatter).to be_an_instance_of(CustomFormatter)
      end
    end
  end

  describe '::log' do
    it 'returns Berkshelf::Logger' do
      expect(Berkshelf.log).to eq(Berkshelf::Logger)
    end
  end
end
