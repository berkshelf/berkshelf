require 'spec_helper'

module Berkshelf
  describe Resolver do
    describe "ClassMethods" do
      subject { Resolver }

      describe "::initialize" do
        let(:downloader) { Berkshelf.downloader }

        it "adds the specified sources to the sources hash" do
          source = CookbookSource.new("mysql", "= 1.2.4")
          resolver = subject.new(downloader, source)

          resolver.should have_source(source)
        end

        it "adds the dependencies of the source as packages of the graph" do
          source = CookbookSource.new("mysql", "= 1.2.4")
          resolver = subject.new(downloader, source)

          source.cached_cookbook.dependencies.each do |name, constraint|
            resolver.package(name).should_not be_nil
          end
        end

        it "adds the version_constraints of the dependencies to the graph" do
          source = CookbookSource.new("mysql", "= 1.2.4")
          resolver = subject.new(downloader, source)

          source.cached_cookbook.dependencies.each do |name, constraint|
            resolver.package(name).versions.should_not be_empty
          end
        end

        context "given an array of sources" do
          it "adds the sources to the sources hash" do
            sources = [CookbookSource.new("mysql", "= 1.2.4")]
            resolver = subject.new(downloader, sources)

            resolver.should have_source(sources[0])
          end
        end
      end
    end

    let(:source) { CookbookSource.new("mysql", "= 1.2.4") }

    subject { Resolver.new(Berkshelf.downloader) }

    describe "#add_source" do
      let(:source) do
        double('source',
          name: 'mysql',
          version_constraint: DepSelector::VersionConstraint.new('= 1.2.4'),
          downloaded?: true,
          cached_cookbook: double('cached_cb', 
            name: 'mysql-1.2.4',
            cookbook_name: 'mysql',
            version: '1.2.4',
            dependencies: Array.new
          ),
          location: double('location')
        )
      end

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
        source.cached_cookbook.dependencies.each do |name, constraint|
          subject.package(name).should_not be_nil
        end
      end

      it "raises a DuplicateSourceDefined exception if a source of the same name is added" do
        subject.should_receive(:has_source?).with(source).and_return(true)

        lambda {
          subject.add_source(source)
        }.should raise_error(DuplicateSourceDefined)
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

    describe "#[]" do
      before(:each) { subject.add_source(source) }

      it "returns the source of the given name" do
        subject[source.name].should eql(source)
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
        @solution = subject.resolve
      end
      
      it "returns an array of CachedCookbooks" do
        @solution.each do |item|
          item.should be_a(CachedCookbook)
        end
      end

      it "returns a CachedCookbook for each resolved source" do
        @solution.should have(2).items
      end

      it "resolves the given mysql source" do
        @solution[0].cookbook_name.should eql("mysql")
        @solution[0].version.should eql("1.2.4")
        @solution[1].cookbook_name.should eql("openssl")
        @solution[1].version.should eql("1.0.0")
      end
    end
  end
end
