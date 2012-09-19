require 'thor/group'

module Berkshelf
  # @author Jamie Winsor <jamie@vialstudios.com>
  class BaseGenerator < Thor::Group
    class << self
      def source_root
        Berkshelf.root.join("generator_files")
      end
    end
    
    include Thor::Actions

    def initialize(*args)
      super(*args)
      self.shell = Berkshelf.ui
    end

    private

      def target
        @target ||= Pathname.new(File.expand_path(path))
      end
  end
end
