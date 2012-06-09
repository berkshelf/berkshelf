require 'spec_helper'

module KnifeCookbookDependencies
  describe TXResult do
    describe "#failed?" do
      subject { TXResult.new(CookbookSource.new("asdf"), :error, "message") }

      it "returns true when the status is :error" do
        subject.failed?.should be_true
      end
    end

    describe "#success" do
      subject { TXResult.new(CookbookSource.new("asdf"), :ok, "message") }

      it "returns true when the status is :ok" do
        subject.success?.should be_true
      end
    end
  end
end
