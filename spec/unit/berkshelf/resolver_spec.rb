require 'spec_helper'

module Berkshelf
  describe Resolver do
    let(:source) do
      double('source',
        name: 'mysql',
        version_constraint: DepSelector::VersionConstraint.new('= 1.2.4'),
        downloaded?: true,
        cached_cookbook: double('mysql-cookbook', 
          name: 'mysql-1.2.4',
          cookbook_name: 'mysql',
          version: '1.2.4',
          dependencies: Array.new
        ),
        location: double('location')
      )
    end

    let(:source_two) do
      double('source-two',
        name: 'nginx',
        version_constraint: DepSelector::VersionConstraint.new('= 0.101.2'),
        downloaded?: true,
        cached_cookbook: double('nginx-cookbook', 
          name: 'nginx-0.101.2',
          cookbook_name: 'nginx',
          version: '0.101.2',
          dependencies: Array.new
        ),
        location: double('location')
      )
    end

    describe "ClassMethods" do
      subject { Resolver }

      describe "::initialize" do
        let(:downloader) { Berkshelf.downloader }

        it "adds the specified sources to the sources hash" do
          resolver = subject.new(downloader, source)

          resolver.should have_source(source.name)
        end

        it "adds the dependencies of the source as sources" do
          resolver = subject.new(downloader, source)

          source.cached_cookbook.dependencies.each do |name, constraint|
            resolver.package(name).should_not be_nil
          end
        end

        it "adds the version_constraints of the dependencies to the graph" do
          resolver = subject.new(downloader, source)

          source.cached_cookbook.dependencies.each do |name, constraint|
            resolver.package(name).versions.should_not be_empty
          end
        end

        context "given an array of sources" do
          it "adds each source to the sources hash" do
            sources = [source]
            resolver = subject.new(downloader, sources)

            resolver.should have_source(sources[0].name)
          end
        end
      end
    end

    subject { Resolver.new(Berkshelf.downloader) }

    describe "#add_source" do
      it "adds the source to the instance of resolver" do
        subject.add_source(source)

        subject.sources.should include(source)
      end

      it "adds a package of the same name of the source to the graph" do
        subject.package(source.name).should_not be_nil
      end

      it "adds a version constraint specified by the source to the package of the same name" do
        subject.add_source(source)

        subject.package(source.name).versions.collect(&:version).should include(source.version_constraint.version)
      end

      it "adds the dependencies of the source as packages to the graph" do
        subject.should_receive(:add_dependencies).with(anything, source.cached_cookbook.dependencies)
        
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
          subject.should_not_receive(:include_dependencies)

          subject.add_source(source, false)
        end
      end
    end

    describe "#add_dependencies" do
      it "adds a package for each dependency to the graph" do
        pkg_ver = subject.add_source(source)
        subject.add_dependencies(pkg_ver, source.cached_cookbook.dependencies)

        subject.package(source.name).should_not be_nil
      end

      it "adds a version constraint to the graph for each dependency" do
        pkg_ver = subject.add_source(source)
        subject.add_dependencies(pkg_ver, source.cached_cookbook.dependencies)

        subject.package(source.name).versions.collect(&:version).should include(source.version_constraint.version)
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

      it "returns a CachedCookbook for each resolved source" do
        @solution.should have(2).items
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
