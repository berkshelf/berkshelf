require "spec_helper"

describe Berkshelf::Resolver do
  let(:berksfile) { double("berksfile") }
  let(:demand) { Berkshelf::Dependency.new(berksfile, "mysql", constraint: "= 1.2.4") }

  before(:each) do
    allow(berksfile).to receive(:required_solver).and_return(nil)
    allow(berksfile).to receive(:preferred_solver).and_return(nil)
  end

  describe "ClassMethods" do
    describe "::initialize" do
      it "adds the specified dependencies to the dependencies hash" do
        resolver = described_class.new(berksfile, demand)
        expect(resolver).to have_demand(demand)
      end
    end
  end

  subject { Berkshelf::Resolver.new(berksfile) }

  describe "#add_demand" do
    it "adds the demand to the instance of resolver" do
      subject.add_demand(demand)
      expect(subject.demands).to include(demand)
    end

    it "raises a DuplicateDemand exception if a demand of the same name is added" do
      expect(subject).to receive(:has_demand?).with(demand).and_return(true)

      expect do
        subject.add_demand(demand)
      end.to raise_error(Berkshelf::DuplicateDemand)
    end
  end

  describe "#demands" do
    it "returns an Array" do
      expect(subject.demands).to be_a(Array)
    end
  end

  describe "#get_demand" do
    before { subject.add_demand(demand) }

    context "given a string representation of the demand to retrieve" do
      it "returns a Berkshelf::Dependency of the same name" do
        expect(subject.get_demand(demand.name)).to eq(demand)
      end
    end
  end

  describe "#has_demand?" do
    before { subject.add_demand(demand) }

    it "returns true if the demand exists" do
      expect(subject.has_demand?(demand.name)).to be(true)
    end

    it "returns false if the demand does not exist" do
      expect(subject.has_demand?("non-existent")).to be(false)
    end
  end

  describe "#resolve" do
    describe "given a missing required solver" do
      before do
        allow(berksfile).to receive(:required_solver).and_return(:xyzzy)
        allow(berksfile).to receive(:preferred_solver).and_return(nil)
      end

      it "should raise an exception about missing required resolver :xyzzy" do
        expect { subject.compute_solver_engine(berksfile) }.to raise_error(/Engine `xyzzy` is not supported/)
      end
    end

    describe "given a missing preferred solver" do
      before do
        allow(berksfile).to receive(:required_solver).and_return(nil)
        allow(berksfile).to receive(:preferred_solver).and_return(:xyzzy)
      end

      it "should not raise an exception about missing preferred resolver :xyzzy" do
        expect { subject.compute_solver_engine(berksfile) }.not_to raise_error
      end
    end
  end
end
