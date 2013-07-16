require 'spec_helper'

describe Berkshelf::Formatters::Null do
  before { Berkshelf.set_format(:null) }

  [:install, :package, :foo, :bar, :bacon].each do |meth|
    it "does not raise an error for :#{meth}" do
      expect {
        subject.send(meth)
      }.to_not raise_error
    end

    it "returns nil for :#{meth}" do
      expect(subject.send(meth)).to be_nil
    end
  end
end
