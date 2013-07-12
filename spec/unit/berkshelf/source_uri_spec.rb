require 'spec_helper'

describe Berkshelf::SourceURI do
  describe "ClassMethods" do
    describe "::parse" do
      subject { described_class.parse(uri) }

      context "when the host is missing" do
        let(:uri) { "http://" }

        it "raises an InvalidSourceURI" do
          expect { subject }.to raise_error(Berkshelf::InvalidSourceURI)
        end
      end
    end
  end

  describe "#validate" do
    subject { described_class.parse(uri) }

    context "when the scheme does not match http or https" do
      let(:uri) { "ftp://riotgames.com" }

      it "raises an InvalidSourceURI" do
        expect { subject.validate }.to raise_error(Berkshelf::InvalidSourceURI)
      end
    end
  end
end
