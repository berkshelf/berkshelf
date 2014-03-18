require 'spec_helper'

module Berkshelf
  describe BaseLocation do
    let(:constraint) { double }
    let(:dependency) { double(name: 'bacon', version_constraint: constraint) }

    subject { described_class.new(dependency) }

    describe '#download' do
      let(:cached) { double }

      it 'validates the returned cached cookbook' do
        expect(subject).to receive(:validate_cached!).with(cached)
        subject.download(cached)
      end

      it 'returns the cached cookbook' do
        subject.stub(:validate_cached!)
        expect(subject.download(cached)).to eq(cached)
      end
    end

    describe '#validate_cached!' do
      let(:cached) { double(name: 'bacon', cookbook_name: 'bacon', version: '0.1.0') }

      it 'raises an error if the version constraint does not satisfy' do
        expect(constraint).to receive(:satisfies?).with(cached.version).and_return(false)

        expect {
          subject.validate_cached!(cached)
        }.to raise_error(CookbookValidationFailure)
      end

      it 'returns true if the cached cookbook satisfies the constraint' do
        expect(constraint).to receive(:satisfies?).with(cached.version).and_return(true)
        expect(subject.validate_cached!(cached)).to be_true
      end

      it 'warns a if the cookbook names do not match' do
        expect(constraint).to receive(:satisfies?).with(cached.version).and_return(true)
        cached.stub(:cookbook_name).and_return('ham')
        msg = Berkshelf::MismatchedCookbookName.new(dependency, cached).to_s

        Berkshelf.ui.should_receive(:warn).with(msg)
        subject.validate_cached!(cached)
      end
    end
  end
end
