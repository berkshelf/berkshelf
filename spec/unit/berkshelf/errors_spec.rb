require 'spec_helper'

describe "berkshelf errors" do
  describe Berkshelf::VagrantWrapperError do
    subject { described_class }

    it "proxies messages to the original exception" do
      original = double('original_error')
      original.should_receive(:a_message)

      subject.new(original).a_message
    end
  end
end
