module Berkshelf
  describe CookbookSource::Location do
    describe "ClassMethods" do
      subject do
        Class.new do
          include CookbookSource::Location
        end
      end

      describe "::location_key" do
        before(:each) do
          @original = CookbookSource.class_variable_get :@@location_keys
          CookbookSource.class_variable_set :@@location_keys, []
        end

        after(:each) do
          CookbookSource.class_variable_set :@@location_keys, @original
        end

        it "adds the given location key to CookbookSource.location_keys" do
          subject.location_key(:reset)

          CookbookSource.location_keys.should have(1).item
          CookbookSource.location_keys.should include(:reset)
        end
      end

      describe "::valid_options" do
        before(:each) do
          @original = CookbookSource.class_variable_get :@@valid_options
          CookbookSource.class_variable_set :@@valid_options, []
        end

        after(:each) do
          CookbookSource.class_variable_set :@@valid_options, @original
        end

        it "adds the given symbol to the list of valid options on CookbookSource" do
          subject.valid_options(:mundo)

          CookbookSource.valid_options.should have(1).item
          CookbookSource.valid_options.should include(:mundo)
        end

        it "adds parameters to the list of valid options on the CookbookSource" do
          subject.valid_options(:riot, :arenanet)

          CookbookSource.valid_options.should have(2).items
          CookbookSource.valid_options.should include(:riot)
          CookbookSource.valid_options.should include(:arenanet)
        end
      end
    end

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
        constraint.should_receive(:satisfies?).with(cached.version).and_return(false)

        lambda {
          subject.validate_cached(cached)
        }.should raise_error(ConstraintNotSatisfied)
      end

      it "returns true if the version constraint satisfies the cached version" do
        constraint.should_receive(:satisfies?).with(cached.version).and_return(true)
        
        subject.validate_cached(cached).should be_true
      end
    end
  end
end
