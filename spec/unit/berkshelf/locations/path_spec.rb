require 'spec_helper'

describe Berkshelf::PathLocation do
  let(:constraint) { double('comp-vconstraint', satisfies?: true) }
  let(:dependency) { double('dep', name: "nginx", version_constraint: constraint) }
  let(:path) { fixtures_path.join('cookbooks', 'example_cookbook').to_s }

  describe "ClassMethods" do
    describe "::new" do
      it 'assigns the value of :path to #path' do
        location = described_class.new(dependency, path: path)
        expect(location.path).to eq(path)
      end
    end
  end

  let(:options) { { path: path } }
  let(:instance) { described_class.new(dependency, options) }

  describe "#download" do
    it "returns a CachedCookbook" do
      expect(instance.download).to be_a(Berkshelf::CachedCookbook)
    end
  end
end
