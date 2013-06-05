require 'spec_helper'

describe Berkshelf do
  describe '.formatter' do
    context 'with default formatter' do
      before { Berkshelf.instance_variable_set(:@formatter, nil) }

      it 'should be human readable' do
        expect(Berkshelf.formatter).to be_an_instance_of(Berkshelf::Formatters::HumanReadable)
      end
    end

    context 'with a custom formatter' do
      before(:all) do
        Berkshelf.instance_eval { @formatter = nil }
      end

      class CustomFormatter
        include Berkshelf::Formatters::AbstractFormatter
        register_formatter :custom
      end

      before do
        Berkshelf.set_format :custom
      end

      it 'is custom class' do
        expect(Berkshelf.formatter).to be_an_instance_of(CustomFormatter)
      end
    end
  end

  describe '.log' do
    it 'returns Berkshelf::Logger' do
      expect(Berkshelf.log).to eq(Berkshelf::Logger)
    end
  end

  describe '#to_s' do
    before { Berkshelf.stub(:berkshelf_path).and_return('/foo/bar') }

    it 'includes the berkshelf path' do
      expect(Berkshelf.to_s).to eq("#<Berkshelf #{subject.berkshelf_path}>")
    end
  end

  describe '#inspect' do
    before do
      Berkshelf.stub(:berkshelf_path).and_return('/foo/bar')
      Berkshelf.stub(:cookbooks_dir).and_return('/zip/zap/cookbooks')
    end

    it 'includes the cookbooks directory' do
      expect(Berkshelf.inspect).to eq("#<Berkshelf #{subject.berkshelf_path}, cookbooks_dir: #{subject.cookbooks_dir}>")
    end
  end
end
