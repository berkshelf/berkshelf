require "spec_helper"

describe Berkshelf::Validator do
  describe "#validate_files" do
    let(:cookbook) { double("cookbook", cookbook_name: "cookbook", path: "path") }

    before do
      allow(Dir).to receive(:chdir) { |&block| block.call }
    end

    it "raises an error when the cookbook has spaces in the files" do
      allow(Dir).to receive(:glob).and_return(["/there are/spaces/in this/recipes/default.rb"])
      expect do
        subject.validate_files(cookbook)
      end.to raise_error(Berkshelf::InvalidCookbookFiles)
    end

    it "does not raise an error when the cookbook is valid" do
      allow(Dir).to receive(:glob).and_return(["/there-are/no-spaces/in-this/recipes/default.rb"])
      expect do
        subject.validate_files(cookbook)
      end.to_not raise_error
    end

    it "does not raise an exception with spaces in the path" do
      allow(Dir).to receive(:glob).and_return(["/there are/spaces/in this/recipes/default.rb"])
      allow_any_instance_of(Pathname).to receive(:dirname).and_return("/there are/spaces/in this")

      expect do
        subject.validate_files(cookbook)
      end.to_not raise_error
    end
  end
end
