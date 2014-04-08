require 'thor/group'

module Berkshelf
  class BaseGenerator < Thor::Group
    class << self
      def source_root
        Berkshelf.root.join('generator_files')
      end
    end

    TYPES = [
      "environment",
      "application",
      "library",
      "wrapper"
    ].freeze

    shell = Berkshelf.ui

    argument :path,
      type: :string,
      required: true

    include Thor::Actions

    private

      def target
        @target ||= Pathname.new(File.expand_path(path))
      end
  end
end
