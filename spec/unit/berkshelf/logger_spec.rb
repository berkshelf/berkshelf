require 'spec_helper'

describe Berkshelf::Logger do
  subject { described_class }

  it "responds to :info" do
    subject.should respond_to(:info)
  end

  it "responds to :warn" do
    subject.should respond_to(:warn)
  end

  it "responds to :error" do
    subject.should respond_to(:error)
  end

  it "responds to :fatal" do
    subject.should respond_to(:fatal)
  end

  it "responds to :debug" do
    subject.should respond_to(:debug)
  end

  it "responds to :deprecate" do
    subject.should respond_to(:deprecate)
  end
end
