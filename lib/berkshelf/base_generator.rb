require 'thor/group'

module Berkshelf
  # @author Jamie Winsor <jamie@vialstudios.com>
  class BaseGenerator < Thor::Group
    class << self
      def source_root
        File.expand_path(File.join(File.dirname(__FILE__), "generator_files"))
      end
    end
    
    include Thor::Actions

    private

      def target
        @target ||= Pathname.new(File.expand_path(path))
      end
  end
end
