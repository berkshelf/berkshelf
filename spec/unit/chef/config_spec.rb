require 'spec_helper'

describe Berkshelf::Chef::Config do
  describe "::path" do
    subject { described_class.path }

    it { should be_a String }
  end
end
