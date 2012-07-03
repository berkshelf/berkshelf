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
  end
end
