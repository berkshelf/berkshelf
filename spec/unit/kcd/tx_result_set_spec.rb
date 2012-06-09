require 'spec_helper'

module KnifeCookbookDependencies
  describe TXResultSet do
    subject { TXResultSet.new }

    let(:failed_result) do
      result = double("result")
      result.stub(:failed?) { true }
      result.stub(:success?) { false }
      result
    end

    let(:successful_result) do
      result = double("result")
      result.stub(:failed?) { false }
      result.stub(:success?) { true }
      result
    end

    describe "#add_result" do
      let(:result) { double("result") }

      it "adds a result to the results attribute" do
        subject.add_result(result)

        subject.results.should have(1).result
      end
    end

    describe "#failed" do
      it "returns the failed results if there were failed results" do
        subject.add_result(failed_result)

        subject.failed.should have(1).result
      end

      it "returns no results if there were no failures" do
        subject.add_result(successful_result)

        subject.failed.should have(0).results
      end
    end

    describe "#success" do
      it "returns the successful results if there were successful results" do
        subject.add_result(successful_result)

        subject.success.should have(1).result
      end

      it "returns no results if there were no successes" do
        subject.add_result(failed_result)

        subject.success.should have(0).results
      end
    end

    describe "#has_errors?" do
      it "returns true if any result was a failure" do
        subject.add_result(failed_result)

        subject.failed.should be_true
      end

      it "returns false if every result was a success" do
        subject.add_result(successful_result)

        subject.failed.should be_true
      end
    end
  end
end
