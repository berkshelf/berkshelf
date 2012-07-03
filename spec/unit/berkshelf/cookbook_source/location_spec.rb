module Berkshelf
  describe CookbookSource::Location do
    let(:name) { "nginx" }
    let(:constraint) { double('constraint') }

    subject do
      Class.new do
        include CookbookSource::Location
      end.new(name, constraint)
    end

    it "sets the downloaded? state to false" do
      subject.downloaded?.should be_false
    end

    describe "#download" do
      it "raises a NotImplementedError if not overridden" do
        lambda {
          subject.download(double('destination'))
        }.should raise_error(NotImplementedError)
      end
    end

    describe "#validate_cached" do
      let(:cached) { double('cached-cb', version: "0.1.0") }

      it "raises a ConstraintNotSatisfied error if the version constraint does not satisfy the cached version" do
        constraint.should_receive(:include?).with(cached.version).and_return(false)

        lambda {
          subject.validate_cached(cached)
        }.should raise_error(ConstraintNotSatisfied)
      end

      it "returns true if the version constraint satisfies the cached version" do
        constraint.should_receive(:include?).with(cached.version).and_return(true)
        
        subject.validate_cached(cached).should be_true
      end
    end
  end
end
