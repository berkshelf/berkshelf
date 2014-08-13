require 'spec_helper'

module Berkshelf
  describe Cli do
    let(:subject) { described_class.new }
    let(:berksfile) { double('Berksfile') }
    let(:cookbooks) { ['mysql'] }

    before do
      allow(Berksfile).to receive(:from_options).and_return(berksfile)
    end

    describe '#upload' do
      it 'calls to upload with params if passed in cli' do
        expect(berksfile).to receive(:upload).with(cookbooks,
          include(skip_syntax_check: true, freeze: false)
        )

        subject.options[:skip_syntax_check] = true
        subject.options[:no_freeze]         = true
        subject.upload('mysql')
      end
    end
  end
end
