require 'spec_helper'

describe Berkshelf::Installer do
  let(:berksfile) { double('berksfile', lockfile: lockfile) }
  let(:lockfile) { double('lockfile') }
  subject { described_class.new(berksfile) }

  describe "#build_universe" do
    let(:source_one) { double('one', uri: 'https://supermarket.chef.io') }
    let(:source_two) { double('two', uri: 'https://api.chef.org') }
    let(:sources) { [ source_one, source_two ] }

    before { allow(berksfile).to receive_messages(sources: sources) }

    it "sends the message #universe on each source" do
      expect(source_one).to receive(:build_universe)
      expect(source_two).to receive(:build_universe)

      subject.build_universe
    end
  end

  describe "#run" do
    context 'when a lockfile is not present' do
      skip
    end

    context 'when a value for :except is given' do
      skip
    end

    context 'when a value for :only is given' do
      skip
    end
  end
end
