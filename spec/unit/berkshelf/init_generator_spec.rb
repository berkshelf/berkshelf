require 'spec_helper'

describe Berkshelf::InitGenerator do
  subject { described_class }

  let(:target) { tmp_path.join("some_cookbook") }

  context "with default options" do
    before(:each) do
      capture(:stdout) {
        subject.new([target]).invoke_all
      }
    end

    specify do
      target.should have_structure {
        file ".gitignore"
        file "Berksfile"
        file "Gemfile" do
          contains "gem 'berkshelf'"
        end
        file "Vagrantfile" do
          contains "require 'berkshelf/vagrant'"
          contains "recipe[some_cookbook::default]"
        end
        no_file "chefignore"
      }
    end
  end

  context "with a chefignore" do
    before(:each) do
      capture(:stdout) {
        subject.new([target], chefignore: true).invoke_all
      }
    end

    specify do
      target.should have_structure {
        file "Berksfile"
        file "chefignore"
      }
    end
  end

  context "with a metadata entry in the Berksfile" do
    before(:each) do
      Dir.mkdir target
      File.open(target.join("metadata.rb"), 'w+') do |f|
        f.write ""
      end
      
      capture(:stdout) {
        subject.new([target], metadata_entry: true).invoke_all
      }
    end

    specify do
      target.should have_structure {
        file "Berksfile" do
          contains "metadata"
        end
      }
    end
  end

  context "with the foodcritic option true" do
    before(:each) do
      capture(:stdout) {
        subject.new([target], foodcritic: true).invoke_all
      }
    end

    specify do
      target.should have_structure {
        file "Thorfile" do
          contains "require 'thor/foodcritic'"
        end
        file "Gemfile" do
          contains "gem 'thor-foodcritic'"
        end
      }
    end
  end

  context "with the scmversion option true" do
    before(:each) do
      capture(:stdout) {
        subject.new([target], scmversion: true).invoke_all
      }
    end

    specify do
      target.should have_structure {
        file "Thorfile" do
          contains "require 'thor/scmversion'"
        end
        file "Gemfile" do
          contains "gem 'thor-scmversion'"
        end
      }
    end
  end

  context "with the bundler option true" do
    before(:each) do
      capture(:stdout) {
        subject.new([target], no_bundler: true).invoke_all
      }
    end

    specify do
      target.should have_structure {
        no_file "Gemfile"
      }
    end
  end

  context "given a value for the cookbook_name option" do
    it "sets the value of cookbook_name attribute to the specified option" do
      generator = subject.new([target], cookbook_name: "nautilus")

      generator.send(:cookbook_name).should eql("nautilus")
    end
  end

  context "when no value for cookbook_name option is specified" do
    it "infers the name of the cookbook from the directory name" do
      generator = subject.new([target])

      generator.send(:cookbook_name).should eql("some_cookbook")
    end
  end

  context "when skipping git" do
    before(:each) do
      generator = subject.new([target], skip_git: true)
      capture(:stdout) { generator.invoke_all }
    end

    it "should not have a .git directory" do
      target.should_not have_structure {
        directory ".git"
      }
    end
  end

  context "when skipping vagrant" do
    before(:each) do
      capture(:stdout) {
        subject.new([target], skip_vagrant: true).invoke_all
      }
    end

    it "should not have a Vagrantfile" do
      target.should have_structure {
        no_file "Vagrantfile"
      }
    end
  end
end
