require "spec_helper"

describe Berkshelf::Lockfile do
  let(:filepath) { fixtures_path.join("lockfiles/default.lock").to_s }
  subject { Berkshelf::Lockfile.new(filepath: filepath) }

  describe ".from_berksfile" do
    let(:lock_path) { File.absolute_path("/path/to/Bacon") }
    let(:berksfile) do
      double("Berksfile",
        filepath: lock_path)
    end

    subject { described_class.from_berksfile(berksfile) }

    it "uses the basename of the Berksfile" do
      expect(subject.filepath).to eq("#{lock_path}.lock")
    end
  end

  describe ".initialize" do
    subject { described_class.new(filepath: filepath) }

    it "sets the instance variables" do
      expect(subject.filepath).to eq(filepath)
      expect(subject.dependencies).to be_a(Array)
      expect(subject.graph).to be_a(Berkshelf::Lockfile::Graph)
    end

    it "has the correct dependencies" do
      expect(subject).to have_dependency("apt")
      expect(subject).to have_dependency("jenkins")
    end
  end

  describe "#parse" do
    let(:parser) { double("parser", run: true) }

    before do
      allow(Berkshelf::Lockfile::LockfileParser).to receive(:new).and_return(parser)
    end

    it "creates a new parser object" do
      expect(Berkshelf::Lockfile::LockfileParser).to receive(:new).with(subject)
      expect(parser).to receive(:run)
      subject.parse
    end

    it "returns true (always)" do
      expect(subject.parse).to be(true)
    end
  end

  describe "#present?" do
    it "returns true when the file exists" do
      expect(subject.present?).to be(true)
    end

    it "returns false when the file does not exist" do
      allow(File).to receive(:exist?).and_return(false)
      expect(subject.present?).to be(false)
    end

    it "returns false when the file is empty" do
      allow(File).to receive(:read).and_return("")
      expect(subject.present?).to be(false)
    end
  end

  describe "#trusted?" do
    it "returns true when the lockfile is trusted" do
      cookbook = double("apt-1.0.0", dependencies: {})
      apt = double("apt",
        name: "apt",
        version_constraint: Semverse::Constraint.new(">= 0.0.0"),
        version: "1.0.0",
        location: "api",
        dependencies: {},
        cached_cookbook: cookbook)
      berksfile = double("berksfile", dependencies: [apt])
      subject.instance_variable_set(:@berksfile, berksfile)
      allow(subject).to receive(:find).with(apt).and_return(apt)
      allow(subject.graph).to receive(:find).with(apt).and_return(apt)

      expect(subject.trusted?).to be(true)
    end

    it "returns true when the lockfile is trusted with transitive dependencies" do
      cookbook = double("apt-1.0.0", dependencies: { "bacon" => "1.0.0" })
      apt = double("apt",
        name: "apt",
        version_constraint: Semverse::Constraint.new(">= 0.0.0"),
        version: "1.0.0",
        location: "api",
        dependencies: { "bacon" => "1.0.0" },
        cached_cookbook: cookbook)
      bacon = double(name: "bacon", version: "1.0.0", dependencies: {})
      berksfile = double("berksfile", dependencies: [apt])
      subject.instance_variable_set(:@berksfile, berksfile)
      allow(subject).to receive(:find).with(apt).and_return(apt)
      allow(subject.graph).to receive(:find).with("bacon").and_return(bacon)
      allow(subject.graph).to receive(:find).with(apt).and_return(apt)

      expect(subject.trusted?).to be(true)
    end

    it "returns true when the lockfile is trusted with cyclic transitive dependencies" do
      cookbook = double("apt-1.0.0", dependencies: { "bacon" => "1.0.0" })
      apt = double("apt",
        name: "apt",
        version_constraint: Semverse::Constraint.new(">= 0.0.0"),
        version: "1.0.0",
        location: "api",
        dependencies: { "bacon" => "1.0.0" },
        cached_cookbook: cookbook)
      bacon = double("bacon",
        name: "bacon",
        version_constraint: Semverse::Constraint.new(">= 0.0.0"),
        version: "1.0.0",
        location: "api",
        dependencies: { "apt" => "1.0.0" })
      berksfile = double("berksfile", dependencies: [apt])
      subject.instance_variable_set(:@berksfile, berksfile)
      allow(subject).to receive(:find).with(apt).and_return(apt)
      allow(subject.graph).to receive(:find).with("bacon").and_return(bacon)
      allow(subject.graph).to receive(:find).with(apt).and_return(apt)

      expect(subject.trusted?).to be(true)
    end

    it "returns false when the lockfile is not trusted because of transitive dependencies" do
      cookbook = double("apt-1.0.0", dependencies: { "bacon" => "1.0.0", "flip" => "2.0.0" })
      apt = double("apt",
        name: "apt",
        version_constraint: Semverse::Constraint.new(">= 0.0.0"),
        version: "1.0.0",
        location: "api",
        dependencies: { "bacon" => "1.0.0" },
        cached_cookbook: cookbook)
      berksfile = double("berksfile", dependencies: [apt])
      subject.instance_variable_set(:@berksfile, berksfile)
      allow(subject).to receive(:find).with(apt).and_return(apt)
      allow(subject.graph).to receive(:find).with(apt).and_return(apt)

      expect(subject.trusted?).to be(false)
    end

    it "returns false if the dependency is not in the lockfile" do
      apt = double("apt", name: "apt", version_constraint: nil)
      berksfile = double("berksfile", dependencies: [apt])
      subject.instance_variable_set(:@berksfile, berksfile)

      expect(subject.trusted?).to be(false)
    end

    it "returns false if the dependency is not in the graph" do
      apt = double("apt", name: "apt", version_constraint: nil)
      berksfile = double("berksfile", dependencies: [apt])
      subject.instance_variable_set(:@berksfile, berksfile)
      allow(subject).to receive(:find).with(apt).and_return(true)
      allow(subject.graph).to receive(:find).with(apt).and_return(nil)

      expect(subject.trusted?).to be(false)
    end

    it "returns false if the constraint is not satisfied" do
      cookbook = double("apt-1.0.0", dependencies: {})
      apt = double("apt",
        name: "apt",
        version_constraint: Semverse::Constraint.new("< 1.0.0"),
        version: "1.0.0",
        location: "api",
        dependencies: {},
        cached_cookbook: cookbook)
      berksfile = double("berksfile", dependencies: [apt])
      subject.instance_variable_set(:@berksfile, berksfile)
      allow(subject).to receive(:find).with(apt).and_return(apt)
      allow(subject.graph).to receive(:find).with(apt).and_return(apt)

      expect(subject.trusted?).to be(false)
    end

    it "returns false if the locations are different" do
      cookbook = double("apt-1.0.0", dependencies: {})
      apt = double("apt",
        name: "apt",
        version_constraint: Semverse::Constraint.new("< 1.0.0"),
        version: "1.0.0",
        location: "api",
        dependencies: {},
        cached_cookbook: cookbook)
      apt_master = apt.dup
      allow(apt_master).to receive_messages(location: "github")
      allow(apt_master).to receive_messages(cached_cookbook: cookbook)
      berksfile = double("berksfile", dependencies: [apt])
      subject.instance_variable_set(:@berksfile, berksfile)
      allow(subject).to receive(:find).with(apt).and_return(apt_master)
      allow(subject.graph).to receive(:find).with(apt).and_return(apt)

      expect(subject.trusted?).to be(false)
    end
  end

  describe "#apply" do
    before do
      apt = double(name: "apt", locked_version: "1.0.0")
      jenkins = double(name: "jenkins", locked_version: "1.4.5")
      allow(subject.graph).to receive(:locks).and_return("apt" => apt, "jenkins" => jenkins)
    end

    describe "when :envfile option is not used" do
      let(:connection) { double("connection") }

      before do
        allow(Berkshelf).to receive(:ridley_connection).and_yield(connection)
      end

      context "when the Chef environment does not exist" do
        it "raises an exception" do
          allow(connection).to receive(:get).and_raise(Berkshelf::APIClient::ServiceNotFound)
          expect do
            subject.apply("production")
          end.to raise_error(Berkshelf::EnvironmentNotFound)
        end
      end

      it "locks the environment cookbook versions on chef server" do
        environment = instance_double(Chef::Environment)
        env_hash = double(Hash)
        expect(connection).to receive(:get).with("environments/production").and_return(env_hash)
        expect(Chef::Environment).to receive(:from_hash).with(env_hash).and_return(environment)

        expect(environment).to receive(:cookbook_versions).with(
          {"apt" => "= 1.0.0",
          "jenkins" => "= 1.4.5"}
        )

        expect(environment).to receive(:save)
        subject.apply("production")
      end
    end

    describe "when :envfile option is used" do
      it "locks the environment cookbook version into envfile" do
        locks = {
          "apt" => "= 1.0.0",
          "jenkins" => "= 1.4.5",
        }

        expect(subject).to receive(:update_environment_file).with("/working/path", locks)

        subject.apply("production", envfile: "/working/path")
      end
    end
  end

  describe "#dependencies" do
    it "returns an array" do
      expect(subject.dependencies).to be_a(Array)
    end
  end

  describe "#find" do
    it "returns a matching cookbook" do
      expect(subject.find("apt").name).to eq("apt")
    end

    it "returns nil for a missing cookbook" do
      expect(subject.find("foo")).to be_nil
    end
  end

  describe "#has_dependency?" do
    it "returns true if a matching cookbook is found" do
      expect(subject).to have_dependency("apt")
    end

    it "returns false if no matching cookbook is found" do
      expect(subject).to_not have_dependency("foo")
    end
  end

  describe "#add" do
    it "adds the dependency to the lockfile" do
      subject.add("apache2")
      expect(subject).to have_dependency("apache2")
    end
  end

  describe "#update_environment_file" do
    it "raises an exception when environment file does not exist" do
      allow(File).to receive(:exist?).and_return(false)
      expect do
        subject.update_environment_file("/broken/path", nil)
      end.to raise_error(Berkshelf::EnvironmentFileNotFound)
    end

    it "updates the environment file with cookbook versions" do
      file = instance_spy("File")
      locks = {
        "apt" => "1.0.0",
        "jenkins" => "1.4.5",
      }

      allow(File).to receive(:exist?).and_return(true)
      allow(File).to receive(:read).and_return("{}")
      allow(File).to receive(:open).and_yield(file)

      subject.update_environment_file("/working/path.json", locks)

      expect(file).to have_received(:puts) do |arg|
        expect(JSON.parse(arg)).to eq({
          "cookbook_versions" => locks,
        })
      end
    end
  end

  describe "#update" do
    it "resets the dependencies" do
      subject.update([])
      expect(subject.dependencies).to be_empty
    end

    it "appends each of the dependencies" do
      subject.update(["apache2"])
      expect(subject).to have_dependency("apache2")
    end
  end

  describe "#unlock" do
    it "removes the dependency from the graph" do
      subject.add("apache2")
      subject.unlock("apache2")
      expect(subject).to_not have_dependency("apache2")
    end
  end

  describe "#reduce!" do
    let(:berksfile_path) { fixtures_path.join("berksfiles/default").to_s }
    let(:berksfile) { Berkshelf::Berksfile.from_file(berksfile_path) }

    describe "with some orphan dependencies" do
      let(:orphans_lock) { fixtures_path.join("lockfiles/orphans.lock").to_s }
      subject { Berkshelf::Lockfile.new(filepath: orphans_lock, berksfile: berksfile) }

      it "removes orphan dependencies" do
        graph = subject.graph.instance_variable_get(:@graph)
        expect(graph).to receive(:delete).with("yum-epel").and_call_original
        expect(graph).to receive(:delete).with("zum-foo").and_call_original
        expect(graph).to receive(:delete).with("yum").and_call_original
        subject.reduce!
      end
    end

    describe "minimizes updates" do
      subject { Berkshelf::Lockfile.new(filepath: filepath, berksfile: berksfile) }

      before(:each) do
        cs = fixtures_path.join("cookbook-store")
        allow(Berkshelf::CookbookStore.instance).to receive(:storage_path).and_return(cs)
      end

      it "uses the cookbook version specified in the lockfile" do
        subject.reduce!
        expect(subject.berksfile.dependencies[1].cached_cookbook.version).to eq("2.0.3")
      end

      it "does not remove locks unnecessarily" do
        expect(subject).to_not receive(:unlock)
        subject.reduce!
      end
    end
  end
end

describe Berkshelf::Lockfile::Graph do
  let(:filepath) { fixtures_path.join("lockfiles/empty.lock").to_s }
  let(:lockfile) { Berkshelf::Lockfile.new(filepath: filepath) }
  subject { described_class.new(lockfile) }

  describe "#update" do
    it "uses cookbook_name as GraphItem name" do
      cookbook = double("test",
        name: "test-0.0.1",
        version: "0.0.1",
        cookbook_name: "test",
        dependencies: {})
      subject.update([cookbook])

      expect(subject.locks.keys).to include(cookbook.cookbook_name)
    end
  end
end
