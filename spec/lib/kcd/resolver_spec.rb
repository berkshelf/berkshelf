require 'spec_helper'

module KnifeCookbookDependencies
  describe Resolver do
    let(:source) { CookbookSource.new("mysql", "= 1.2.4") }

    subject do
      source.download(tmp_path)
      Resolver.new(source)
    end

    describe "#initialize" do
      it "adds a package named after the given source's name" do
        subject.prime_package.name.should eql(source.name)
      end

      it "sets a prime_version equal to the cookbook's version" do
        subject.prime_version.version.to_s.should eql("1.2.4")
      end
    end

    describe "#resolve_prime" do
      it "fucks up" do
        s1 = CookbookSource.new("openssl")
        s1.download(tmp_path)

        subject.add_source(s1)
        subject.resolve_prime.should eql("mysql" => DepSelector::Version.new("1.2.4"), "openssl" => DepSelector::Version.new("1.0.0"))
      end
    end
  end
end
