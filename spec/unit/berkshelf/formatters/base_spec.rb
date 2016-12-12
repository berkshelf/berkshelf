require "spec_helper"

module Berkshelf
  describe BaseFormatter do
    it "has abstract methods for all the messaging modes" do
      expect do
        subject.install("my_coobook", "1.2.3", "http://community")
      end.to raise_error(AbstractFunction)

      expect do
        subject.use("my_coobook", "1.2.3")
      end.to raise_error(AbstractFunction)

      expect do
        subject.use("my_coobook", "1.2.3", "http://community")
      end.to raise_error(AbstractFunction)

      expect do
        subject.uploaded("my_coobook", "1.2.3", "http://chef_server")
      end.to raise_error(AbstractFunction)

      expect do
        subject.msg("something you to know")
      end.to raise_error(AbstractFunction)

      expect do
        subject.error("whoa this is bad")
      end.to raise_error(AbstractFunction)

      expect do
        subject.fetch(double("dependency"))
      end.to raise_error(AbstractFunction)
    end
  end
end
