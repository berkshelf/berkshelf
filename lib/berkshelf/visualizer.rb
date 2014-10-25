require 'buff/shell_out'
require 'set'
require 'tempfile'

module Berkshelf
  class Visualizer
    class << self
      def from_lockfile(lockfile)
        new.tap do |instance|
          lockfile.graph.each do |item|
            instance.node(item.name)

            item.dependencies.each do |name, version|
              instance.edge(item.name, name, version)
            end
          end
        end
      end
    end

    include Buff::ShellOut

    def initialize
      @nodes = {}
    end

    def node(object)
      @nodes[object] ||= Set.new
      self
    end

    def nodes
      @nodes.keys
    end

    def each_node(&block)
      nodes.each(&block)
    end

    def edge(a, b, version)
      node(a)
      node(b)

      @nodes[a].add(b => version)
    end

    def adjacencies(object)
      @nodes[object] || Set.new
    end

    # Convert the current graph to a DOT. This is an intermediate step in
    # generating a PNG.
    #
    # @return [String]
    def to_dot
      out = %|digraph Solve__Graph {\n|

      nodes.each do |node|
        out << %|  "#{node}" [ fontsize = 10, label = "#{node}" ]\n|
      end

      nodes.each do |node|
        adjacencies(node).each do |edge|
          edge.each do |name, version|
            if version == Semverse::DEFAULT_CONSTRAINT
              label = ""
            else
              label = " #{version}"
            end
            out << %|  "#{node}" -> "#{name}" [ fontsize = 10, label = "#{label}" ]\n|
          end
        end
      end

      out << %|}|
      out
    end

    # Save the graph visually as a PNG.
    #
    # @param [String] outfile
    #   the name/path of the file to output
    #
    # @return [String]
    #   the path where the file was written
    def to_png(outfile = 'graph.png')
      tempfile = Tempfile.new('dotdotfile')
      tempfile.write(to_dot)
      tempfile.rewind

      unless Berkshelf.which('dot') || Berkshelf.which('dot.exe')
        raise GraphvizNotInstalled.new
      end

      command = %|dot -T png #{tempfile.path} -o "#{outfile}"|
      response = shell_out(command)

      unless response.success?
        raise GraphvizCommandFailed.new(command, response.stderr)
      end

      File.expand_path(outfile)
    ensure
      if tempfile && File.exist?(tempfile.path)
        tempfile.close
        tempfile.unlink
      end
    end
  end
end
