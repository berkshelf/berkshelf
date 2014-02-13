require 'spec_helper'

describe Berkshelf::Installer do
  let(:berksfile) { double('berksfile', lockfile: lockfile) }
  let(:lockfile) { double('lockfile') }
  subject { described_class.new(berksfile) }

  describe "#build_universe" do
    let(:source_one) { double('one') }
    let(:source_two) { double('two') }
    let(:sources) { [ source_one, source_two ] }

    before { berksfile.stub(sources: sources) }

    it "sends the message #universe on each source" do
      source_one.should_receive(:build_universe)
      source_two.should_receive(:build_universe)

      subject.build_universe
    end
  end

  describe "#run" do
    context 'when a lockfile is not present' do
      pending
    end

    context 'when a value for :except is given' do
      pending
    end

    context 'when a value for :only is given' do
      pending
    end
  end
end
