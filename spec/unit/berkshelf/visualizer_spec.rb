require 'rspec'
require 'spec_helper'

module Berkshelf
  describe Visualizer do
    describe '#to_png' do
      context 'when graphviz is not installed' do
        before do
          allow(Berkshelf).to receive(:which)
            .with('dot')
            .and_return(nil)
        end

        it 'raises a GraphvizNotInstalled exception' do
          expect { subject.to_png }.to raise_error(GraphvizNotInstalled)
        end
      end

      context 'when the graphviz command fails', :graphviz do
        before do
          response = double(success?: false, stderr: 'Something happened!')
          allow(subject).to receive(:shell_out).and_return(response)
        end

        it 'raises a GraphvizCommandFailed exception' do
          expect { subject.to_png }.to raise_error(GraphvizCommandFailed)
        end
      end

      context 'when graphviz is installed', :requires_dot => true do
        it 'builds a png' do
          outfile = tmp_path.join('test-graph.png').to_s
          lockfile = Lockfile.from_file fixtures_path.join('lockfiles/default.lock').to_s
          Visualizer.from_lockfile(lockfile).to_png(outfile)
        end
      end
    end
  end
end
