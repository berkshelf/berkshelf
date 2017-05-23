require "spec_helper"

module Berkshelf
  describe ChefRepoUniverse do
    let(:fixture) { nil }
    let(:fixture_path) { File.expand_path("../../../fixtures/#{fixture}", __FILE__) }
    subject { described_class.new("file://#{fixture_path}", path: fixture_path).universe }

    context "with cookbooks in ./" do
      let(:fixture) { "cookbook-path" }

      it "returns the correct universe" do
        expect(subject.size).to eq 1
        expect(subject[0].name).to eq "jenkins-config"
        expect(subject[0].version).to eq "0.1.0"
        expect(subject[0].dependencies).to eq "jenkins" => "~> 2.0"
      end
    end

    context "with cookbooks in cookbooks/" do
      let(:fixture) { "complex-cookbook-path" }

      it "returns the correct universe" do
        expect(subject.size).to eq 3
        expect(subject[0].name).to eq "app"
        expect(subject[0].version).to eq "1.2.3"
        expect(subject[0].dependencies).to eq({})
        expect(subject[1].name).to eq "jenkins"
        expect(subject[1].version).to eq "2.0.1"
        expect(subject[1].dependencies).to eq({})
        expect(subject[2].name).to eq "jenkins-config"
        expect(subject[2].version).to eq "0.1.0"
        expect(subject[2].dependencies).to eq "jenkins" => "~> 2.0"
      end
    end
  end
end
