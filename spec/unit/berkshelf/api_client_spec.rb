require 'spec_helper'

describe Berkshelf::APIClient do
  describe '#universe' do
    it 'returns an array of RemoteCookbook objects' do
      subject.stub(:get).with('universe').and_return(
        double('response', status: 200, parsed: {
          'berkshelf' => {
            '1.0.0' => {},
          },
        })
      )

      universe = subject.universe
      expect(universe).to be_a(Array)
      expect(universe.first).to be_a(Berkshelf::APIClient::RemoteCookbook)
    end

    it 'has an item for each dependency' do
      subject.stub(:get).with('universe').and_return(
        double('response', status: 200, parsed: {
          'berkshelf' => {
            '1.0.0' => {},
            '1.0.2' => {},
          },
          'ridley' => {
            '1.0.5' => {},
          },
        })
      )

      universe = subject.universe

      expect(universe).to have(3).items
      expect(universe[0].name).to eq('berkshelf')
      expect(universe[0].version).to eq('1.0.0')
    end

    it 'has dependencies' do
      subject.stub(:get).with('universe').and_return(
        double('response', status: 200, parsed: {
          'berkshelf' => {
            '1.0.0' => { 'dependencies' => { 'ridley' => '>= 1.0.0' } },
          },
        })
      )

      cookbook = subject.universe.first
      expect(cookbook.dependencies).to eq('ridley' => '>= 1.0.0')
    end

    it 'has platforms' do
      subject.stub(:get).with('universe').and_return(
        double('response', status: 200, parsed: {
          'berkshelf' => {
            '1.0.0' => { 'platforms' => { 'CentOS' => '>= 5.0' } },
          },
        })
      )

      cookbook = subject.universe.first
      expect(cookbook.platforms).to eq('CentOS' => '>= 5.0')
    end

    it 'has a location_path' do
      subject.stub(:get).with('universe').and_return(
        double('response', status: 200, parsed: {
          'berkshelf' => {
            '1.0.0' => { 'location_path' => '/path/to/src' },
          },
        })
      )

      cookbook = subject.universe.first
      expect(cookbook.location_path).to eq('/path/to/src')
    end

    it 'has a location_type' do
      subject.stub(:get).with('universe').and_return(
        double('response', status: 200, parsed: {
          'berkshelf' => {
            '1.0.0' => { 'location_type' => 'git' },
          },
        })
      )

      cookbook = subject.universe.first
      expect(cookbook.location_type).to eq(:git)
    end
  end
end
