require 'spec_helper'

describe Berkshelf::Formatters do
  before do
    @original = Berkshelf::Formatters.class_variable_get :@@formatters
    Berkshelf::Formatters.class_variable_set :@@formatters, {}
  end

  after do
    Berkshelf::Formatters.class_variable_set :@@formatters, @original
  end

  let(:format_id) { :rspec }
  let(:format_klass) { Class.new { include Berkshelf::Formatters::AbstractFormatter } }

  describe '.register' do
    it 'adds the class of the includer to the list of registered formatters with the id' do
      Berkshelf::Formatters.register(format_id, format_klass)

      expect(Berkshelf::Formatters.formatters).to have_key(format_id)
      expect(Berkshelf::Formatters.formatters[format_id]).to eq(format_klass)
    end

    context 'when given a string instead of a symbol as the ID' do
      it 'converts the string to a symbol and registers it' do
        Berkshelf::Formatters.register('rspec', format_klass)

        expect(Berkshelf::Formatters.formatters).to have_key(:rspec)
        expect(Berkshelf::Formatters.formatters[:rspec]).to eq(format_klass)
      end
    end

    context 'when a formatter of the given ID has already been registered' do
      it 'raises an InternalError' do
        Berkshelf::Formatters.register(format_id, format_klass)

        expect {
          Berkshelf::Formatters.register(format_id, format_klass)
        }.to raise_error(Berkshelf::InternalError)
      end
    end
  end

  describe '.formatters' do
    before do
      Berkshelf::Formatters.register(format_id, format_klass)
    end

    it "returns a hash where formatter ID's are keys and values are formatter classes" do
      expect(Berkshelf::Formatters.formatters).to be_a(Hash)
      expect(Berkshelf::Formatters.formatters).to have(1).item
      expect(Berkshelf::Formatters.formatters.keys.first).to eq(format_id)
      expect(Berkshelf::Formatters.formatters.values.first).to eq(format_klass)
    end
  end

  describe '.get' do
    before { Berkshelf::Formatters.register(format_id, format_klass) }

    it 'returns the class constant of the given formatter ID' do
      expect(Berkshelf::Formatters[format_id]).to eq(format_klass)
    end

    context 'when the ID has not been registered' do
      it 'returns nil' do
        expect(Berkshelf::Formatters[:not_there]).to be_nil
      end
    end
  end

  describe Berkshelf::Formatters::AbstractFormatter do
    describe '.register_formatter' do
      it 'delegates to Formatters' do
        Berkshelf::Formatters.should_receive(:register).with(:rspec, format_klass)

        format_klass.register_formatter(:rspec)
      end
    end



    subject do
      Class.new { include Berkshelf::Formatters::AbstractFormatter }.new
    end

    it 'has abstract methods for all the messaging modes' do
      expect {
        subject.install('my_coobook','1.2.3','http://community')
      }.to raise_error(Berkshelf::AbstractFunction)

      expect {
        subject.use('my_coobook','1.2.3')
      }.to raise_error(Berkshelf::AbstractFunction)

      expect {
        subject.use('my_coobook','1.2.3','http://community')
      }.to raise_error(Berkshelf::AbstractFunction)

      expect {
        subject.upload('my_coobook','1.2.3','http://chef_server')
      }.to raise_error(Berkshelf::AbstractFunction)

      expect {
        subject.msg('something you to know')
      }.to raise_error(Berkshelf::AbstractFunction)

      expect {
        subject.error('whoa this is bad')
      }.to raise_error(Berkshelf::AbstractFunction)
    end
  end
end
