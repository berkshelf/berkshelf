require 'spec_helper'

module Berkshelf
  describe Resolver do
    let(:source) do
      double('source',
        name: 'mysql',
        version_constraint: Solve::Constraint.new('= 1.2.4'),
        downloaded?: true,
        cached_cookbook: double('mysql-cookbook', 
          name: 'mysql-1.2.4',
          cookbook_name: 'mysql',
          version: '1.2.4',
          dependencies: { "nginx" => ">= 0.1.0", "artifact" => "~> 0.10.0" }
        ),
        location: double('location', validate_cached: true)
      )
    end

    let(:source_two) do
      double('source-two',
        name: 'nginx',
        version_constraint: Solve::Constraint.new('= 0.101.2'),
        downloaded?: true,
        cached_cookbook: double('nginx-cookbook', 
          name: 'nginx-0.101.2',
          cookbook_name: 'nginx',
          version: '0.101.2',
          dependencies: Hash.new
        ),
        location: double('location', validate_cached: true)
      )
    end

    describe "ClassMethods" do
      subject { Resolver }

      describe "::initialize" do
        let(:downloader) { Berkshelf.downloader }

        it "adds the specified sources to the sources hash" do
          resolver = subject.new(downloader, sources: source)

          resolver.should have_source(source.name)
        end

        it "adds the dependencies of the source as sources" do
          resolver = subject.new(downloader, sources: source)
          
          resolver.should have_source("nginx")
          resolver.should have_source("artifact")
        end

        context "given no option for :locations" do
          it "adds the default Opscode Community Site to the array of locations" do
            resolver = subject.new(downloader)

            resolver.locations.should have(1).item
            resolver.locations[0][:type].should eql(:site)
            resolver.locations[0][:value].should eql(:opscode)
          end
        end

        context "given a value for :locations" do
          it "adds the value for locations to the array of locations" do
            resolver = subject.new(downloader, locations: [{ type: :path, value: "/Users/reset/cookbooks/nginx", options: Hash.new }])

            resolver.locations.should have(1).item
            resolver.locations[0][:type].should eql(:path)
            resolver.locations[0][:value].should eql("/Users/reset/cookbooks/nginx")
          end
        end

        context "given an array of sources" do
          it "adds each source to the sources hash" do
            sources = [source]
            resolver = subject.new(downloader, sources: sources)

            resolver.should have_source(sources[0].name)
          end
        end
      end
    end

    subject { Resolver.new(Berkshelf.downloader) }

    describe "#add_source" do
      let(:package_version) { double('package-version', dependencies: Array.new) }

      it "adds the source to the instance of resolver" do
        subject.add_source(source)

        subject.sources.should include(source)
      end

      it "adds an artifact of the same name of the source to the graph" do
        subject.graph.should_receive(:artifacts).with(source.name, source.cached_cookbook.version)
        
        subject.add_source(source, false)
      end

      it "adds the dependencies of the source as packages to the graph" do
        subject.should_receive(:add_source_dependencies).with(source)
        
        subject.add_source(source)
      end

      it "raises a DuplicateSourceDefined exception if a source of the same name is added" do
        subject.should_receive(:has_source?).with(source).and_return(true)

        lambda {
          subject.add_source(source)
        }.should raise_error(DuplicateSourceDefined)
      end

      context "when include_dependencies is false" do
        it "does not try to include_dependencies" do
          subject.should_not_receive(:add_source_dependencies)

          subject.add_source(source, false)
        end
      end
    end

    describe "#get_source" do
      before(:each) { subject.add_source(source) }

      context "given a string representation of the source to retrieve" do
        it "returns the source of the same name" do
          subject.get_source(source.name).should eql(source)
        end
      end       
    end

    describe "#has_source?" do
      before(:each) { subject.add_source(source) }

      it "returns the source of the given name" do
        subject.has_source?(source.name).should be_true
      end
    end

    describe "#resolve" do
      before(:each) do
        subject.add_source(source)
        subject.add_source(source_two)
        @solution = subject.resolve
      end
      
      it "returns an array of the CachedCookbooks which make up the solution" do
        @solution.should include(source.cached_cookbook)
        @solution.should include(source_two.cached_cookbook)
      end
      
      it "resolves the given mysql source" do
        @solution[0].cookbook_name.should eql("mysql")
        @solution[0].version.should eql("1.2.4")
        @solution[1].cookbook_name.should eql("nginx")
        @solution[1].version.should eql("0.101.2")
      end
    end
  end
end
