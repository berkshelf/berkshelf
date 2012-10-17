require 'spec_helper'

describe Berkshelf::Config do
  subject { config }

  let(:config) { klass.new }
  let(:klass) { described_class }

  its(:present?) { should be_false }

  it "set and gets hash keys" do
    config[:a] = 1
    config[:a].should == 1
  end

  it "does not raise an error for nested hash keys that have not been set" do
    config[:d][:e]
  end

  it "has indifferent access" do
    config[:a] = 1
    config['b'] = 2

    config['a'].should == 1
    config[:b].should == 2
  end

  describe ".file" do
    subject { klass.file }

    context "when the file does not exist" do
      before :each do
        File.stub exists?: false
      end

      it { should be_nil }
    end
  end

  describe ".from_json" do
    subject(:config) { klass.from_json json }

    let(:json) {
      <<-JSON
        {
          "a": 1,
          "b": {
            "c": 2
          }
        }
      JSON
    }

    it "has data" do
      config[:a].should == 1
    end

    it "has nested data" do
      config[:b][:c].should == 2
    end

    it "does not raise and error for nested hash keys that have not been set" do
      config[:d][:e]
    end

    it "has indifferent access" do
      config[:a] = 1
      config['b'] = 2

      config['a'].should == 1
      config[:b].should == 2
    end
  end

  describe ".instance" do
    subject { klass.instance }

    it { should be_a klass }
  end

  describe ".path" do
    subject { klass.path }

    it { should be_a String }
  end
end
