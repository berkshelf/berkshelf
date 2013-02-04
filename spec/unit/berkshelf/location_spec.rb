module Berkshelf
  describe Location do
    describe "ClassMethods Module" do
      subject do
        Class.new do
          include Location
        end
      end

      describe "::set_location_key" do
        before(:each) do
          @original = CookbookSource.class_variable_get :@@location_keys
          CookbookSource.class_variable_set :@@location_keys, {}
        end

        after(:each) do
          CookbookSource.class_variable_set :@@location_keys, @original
        end

        it "adds the given location key with the includer's Class to CookbookSource.location_keys" do
          subject.set_location_key(:reset)

          expect(CookbookSource.location_keys).to have(1).item
          expect(CookbookSource.location_keys).to include(:reset)
          expect(CookbookSource.location_keys[:reset]).to eql(subject)
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

        it "returns the class' registered location key" do
          subject.set_location_key(:reset)

          expect(subject.location_key).to eql(:reset)
        end
      end

      describe "::set_valid_options" do
        before(:each) do
          @original = CookbookSource.class_variable_get :@@valid_options
          CookbookSource.class_variable_set :@@valid_options, []
        end

        after(:each) do
          CookbookSource.class_variable_set :@@valid_options, @original
        end

        it "adds the given symbol to the list of valid options on CookbookSource" do
          subject.set_valid_options(:mundo)

          expect(CookbookSource.valid_options).to have(1).item
          expect(CookbookSource.valid_options).to include(:mundo)
        end

        it "adds parameters to the list of valid options on the CookbookSource" do
          subject.set_valid_options(:riot, :arenanet)

          expect(CookbookSource.valid_options).to have(2).items
          expect(CookbookSource.valid_options).to include(:riot)
          expect(CookbookSource.valid_options).to include(:arenanet)
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

          expect(result[0]).to eql("0.101.2")
        end

        it "returns an array containing a URI at index 0" do
          result = subject.solve_for_constraint(constraint, versions)

          expect(result[1]).to match(URI.regexp)
        end

        it "should return the best match for the constraint and versions given" do
          expect(subject.solve_for_constraint(constraint, versions)[0].to_s).to eql("0.101.2")
        end

        context "given a solution can not be found for constraint" do
          it "returns nil" do
            expect(subject.solve_for_constraint(Solve::Constraint.new(">= 1.0"), versions)).to be_nil
          end
        end
      end
    end

    describe "ModuleFunctions" do
      subject { Location }

      describe "::init" do
        let(:name) { "artifact" }
        let(:constraint) { double("constraint") }

        it "returns an instance of SiteLocation given a site: option key" do
          result = subject.init(name, constraint, site: "http://site/value")

          expect(result).to be_a(SiteLocation)
        end

        it "returns an instance of PathLocation given a path: option key" do
          result = subject.init(name, constraint, path: "/Users/reset/code")

          expect(result).to be_a(PathLocation)
        end

        it "returns an instance of GitLocation given a git: option key" do
          result = subject.init(name, constraint, git: "git://github.com/something.git")

          expect(result).to be_a(GitLocation)
        end

        it "returns an instance of SiteLocation when no option key is given that matches a registered location_key" do
          result = subject.init(name, constraint)

          expect(result).to be_a(SiteLocation)
        end

        context "given two location_keys" do
          it "raises an InternalError" do
            expect {
              subject.init(name, constraint, git: :value, path: :value)
            }.to raise_error(InternalError)
          end
        end
      end
    end

    let(:name) { "nginx" }
    let(:constraint) { double('constraint') }

    subject do
      Class.new do
        include Location
      end.new(name, constraint)
    end

    it "sets the downloaded? state to false" do
      expect(subject.downloaded?).to be_false
    end

    describe "#download" do
      it "raises a AbstractFunction if not defined" do
        expect {
          subject.download(double('destination'))
        }.to raise_error(AbstractFunction)
      end
    end

    describe "#validate_cached" do
      let(:cached) { double('cached-cb', cookbook_name: name, version: "0.1.0") }

      it "raises a ConstraintNotSatisfied error if the version constraint does not satisfy the cached version" do
        constraint.should_receive(:satisfies?).with(cached.version).and_return(false)

        expect {
          subject.validate_cached(cached)
        }.to raise_error(ConstraintNotSatisfied)
      end

      it "returns true if cached_cookbooks satisfies the version constraint" do
        constraint.should_receive(:satisfies?).with(cached.version).and_return(true)

        expect(subject.validate_cached(cached)).to be_true
      end

      context "when the cached_cookbooks satisfies the version constraint" do
        it "returns true if the name of the cached_cookbook matches the name of the location" do
          constraint.should_receive(:satisfies?).with(cached.version).and_return(true)
          cached.stub(:name) { name }

          expect(subject.validate_cached(cached)).to be_true
        end

        it "raises an AmbiguousCookbookName error if the cached_cookbook's name does not match the location's" do
          pending "Implement when Opscode makes the 'name' a required attribute in Cookbook metadata"

          constraint.should_receive(:satisfies?).with(cached.version).and_return(true)
          cached.stub(:cookbook_name) { "artifact" }

          expect {
            subject.validate_cached(cached)
          }.to raise_error(AmbiguousCookbookName)
        end
      end
    end
  end
end
