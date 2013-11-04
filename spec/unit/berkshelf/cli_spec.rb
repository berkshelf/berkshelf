require 'spec_helper'

describe Berkshelf::Cli do
  let(:subject) { described_class.new }
  let(:berksfile) { double('Berksfile') }
  let(:cookbooks) { ['mysql'] }
  describe '#upload' do
    it 'calls to upload with params if passed in cli' do
      Berkshelf::Berksfile.should_receive(:from_file).and_return(berksfile)
      berksfile.should_receive(:upload).with(include(:skip_syntax_check => true, :freeze => false, :cookbooks => cookbooks))
      subject.options[:skip_syntax_check] = true
      subject.options[:no_freeze] = true
      subject.upload('mysql')
    end
  end
end
