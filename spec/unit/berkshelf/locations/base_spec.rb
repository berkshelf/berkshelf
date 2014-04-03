require 'spec_helper'

module Berkshelf
  describe BaseLocation do
    let(:constraint) { double('constraint') }
    let(:dependency) { double('dependency', name: 'cookbook', version_constraint: constraint) }

    subject { described_class.new(dependency) }

    describe '#installed?' do
      it 'is an abstract function' do
        expect { subject.installed? }.to raise_error(AbstractFunction)
      end
    end

    describe '#install' do
      it 'is an abstract function' do
        expect { subject.install }.to raise_error(AbstractFunction)
      end
    end

    describe '#cached_cookbook' do
      it 'is an abstract function' do
        expect { subject.cached_cookbook }.to raise_error(AbstractFunction)
      end
    end

    describe '#to_lock' do
      it 'is an abstract function' do
        expect { subject.to_lock }.to raise_error(AbstractFunction)
      end
    end

    describe '#validate_cached!' do
      context 'when the path is not a cookbook' do
        before { File.stub(:cookbook?).and_return(false) }

        it 'raises an error' do
          expect {
            subject.validate_cached!('/foo/bar')
          }.to raise_error(NotACookbook)
        end
      end

      context 'when the path is a cookbook' do
        let(:cookbook) do
          double('cookbook',
            cookbook_name: 'cookbook',
            version: '0.1.0',
          )
        end

        before do
          File.stub(:cookbook?).and_return(true)
          CachedCookbook.stub(:from_path).and_return(cookbook)
        end

        it 'raises an error if the constraint does not satisfy' do
          constraint.stub(:satisfies?).with('0.1.0').and_return(false)
          expect {
            subject.validate_cached!(cookbook)
          }.to raise_error(CookbookValidationFailure)
        end

        it 'raises an error if the names do not match' do
          constraint.stub(:satisfies?).with('0.1.0').and_return(true)
          cookbook.stub(:cookbook_name).and_return('different_name')
          expect {
            subject.validate_cached!(cookbook)
          }.to raise_error(MismatchedCookbookName)
        end

        it 'returns true when the validation succeeds' do
          constraint.stub(:satisfies?).with('0.1.0').and_return(true)
          expect(subject.validate_cached!(cookbook)).to be_true
        end
      end
    end
  end
end
