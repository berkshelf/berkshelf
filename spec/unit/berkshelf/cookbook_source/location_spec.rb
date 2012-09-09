module Berkshelf
  describe CookbookSource::Location do
    describe "ClassMethods Module" do
      subject do
        Class.new do
          include CookbookSource::Location
        end
      end

      describe "::location_key" do
        before(:each) do
          @original = CookbookSource.class_variable_get :@@location_keys
          CookbookSource.class_variable_set :@@location_keys, {}
        end

        after(:each) do
          CookbookSource.class_variable_set :@@location_keys, @original
        end

        it "adds the given location key with the includer's Class to CookbookSource.location_keys" do
          subject.location_key(:reset)

          CookbookSource.location_keys.should have(1).item
          CookbookSource.location_keys.should include(:reset)
          CookbookSource.location_keys[:reset].should eql(subject)
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

      describe "::solve_for_constraint" do
        let(:constraint) { "~> 0.101.2" }
        let(:versions) do
          { 
            "0.101.2" => "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_101_2",
            "0.101.0" => "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_101_0",
            "0.100.2" => "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_100_2",
            "0.100.0" => "http://cookbooks.opscode.com/api/v1/cookbooks/nginx/versions/0_100_0"
          }
        end

        it "returns an array with a string containing the version of the solution at index 0" do
          result = subject.solve_for_constraint(constraint, versions)

          result[0].should eql("0.101.2")
        end

        it "returns an array containing a URI at index 0" do
          result = subject.solve_for_constraint(constraint, versions)

          result[1].should match(URI.regexp)
        end

        it "should return the best match for the constraint and versions given" do
          subject.solve_for_constraint(constraint, versions)[0].to_s.should eql("0.101.2")
        end

        context "given a solution can not be found for constraint" do
          it "returns nil" do
            subject.solve_for_constraint(Solve::Constraint.new(">= 1.0"), versions).should be_nil
          end
        end
      end
    end

    describe "ModuleFunctions" do
      subject { CookbookSource::Location }

      describe "::init" do
        let(:name) { "artifact" }
        let(:constraint) { double("constraint") }

        it "returns an instance of SiteLocation given a site: option key" do
          result = subject.init(name, constraint, site: "http://site/value")

          result.should be_a(CookbookSource::SiteLocation)
        end

        it "returns an instance of PathLocation given a path: option key" do
          result = subject.init(name, constraint, path: "/Users/reset/code")

          result.should be_a(CookbookSource::PathLocation)
        end

        it "returns an instance of GitLocation given a git: option key" do
          result = subject.init(name, constraint, git: "git://github.com/something.git")

          result.should be_a(CookbookSource::GitLocation)
        end

        it "returns an instance of SiteLocation when no option key is given that matches a registered location_key" do
          result = subject.init(name, constraint)

          result.should be_a(CookbookSource::SiteLocation)
        end

        context "given two location_keys" do
          it "raises an InternalError" do
            lambda {
              subject.init(name, constraint, git: :value, path: :value)
            }.should raise_error(InternalError)
          end
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
      it "raises a AbstractFunction if not defined" do
        lambda {
          subject.download(double('destination'))
        }.should raise_error(AbstractFunction)
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
