require 'spec_helper'

module Berkshelf
  describe BaseFormatter do
    it 'has abstract methods for all the messaging modes' do
      expect {
        subject.install('my_coobook','1.2.3','http://community')
      }.to raise_error(AbstractFunction)

      expect {
        subject.use('my_coobook','1.2.3')
      }.to raise_error(AbstractFunction)

      expect {
        subject.use('my_coobook','1.2.3','http://community')
      }.to raise_error(AbstractFunction)

      expect {
        subject.upload('my_coobook','1.2.3','http://chef_server')
      }.to raise_error(AbstractFunction)

      expect {
        subject.msg('something you to know')
      }.to raise_error(AbstractFunction)

      expect {
        subject.error('whoa this is bad')
      }.to raise_error(AbstractFunction)

      expect {
        subject.fetch(double('dependency'))
      }.to raise_error(AbstractFunction)
    end
  end
end
