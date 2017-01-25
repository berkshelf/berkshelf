require "spec_helper"

module Berkshelf
  describe ".formatter" do
    context "with default formatter" do
      before { Berkshelf.instance_variable_set(:@formatter, nil) }

      it "is human readable" do
        expect(Berkshelf.formatter).to be_an_instance_of(HumanFormatter)
      end
    end

    context "with a custom formatter" do
      before(:all) do
        Berkshelf.instance_eval { @formatter = nil }
      end

      class CustomFormatter < BaseFormatter; end

      before do
        Berkshelf.set_format :custom
      end

      it "is custom class" do
        expect(Berkshelf.formatter).to be_an_instance_of(CustomFormatter)
      end
    end
  end

  describe ".berkshelf_path" do
    before { Berkshelf.instance_variable_set(:@berkshelf_path, nil) }

    context "with default path" do
      before do
        @berkshelf_path = ENV["BERKSHELF_PATH"]
        ENV["BERKSHELF_PATH"] = nil
      end

      after do
        ENV["BERKSHELF_PATH"] = @berkshelf_path
      end

      it "is ~/.berkshelf" do
        expect(Berkshelf.berkshelf_path).to eq File.expand_path("~/.berkshelf")
        expect(Berkshelf.instance_variable_get(:@berkshelf_path)).to eq File.expand_path("~/.berkshelf")
      end
    end

    context 'with ENV["BERKSHELF_PATH"]' do
      it 'is ENV["BERKSHELF_PATH"]' do
        expect(Berkshelf.berkshelf_path).to eq File.expand_path(ENV["BERKSHELF_PATH"])
        expect(Berkshelf.instance_variable_get(:@berkshelf_path)).to eq File.expand_path(ENV["BERKSHELF_PATH"])
      end
    end
  end

  describe "::log" do
    it "returns Berkshelf::Logger" do
      expect(Berkshelf.log).to be_a(Berkshelf::Logger)
    end
  end
end
