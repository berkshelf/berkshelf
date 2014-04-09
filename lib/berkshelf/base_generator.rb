require 'thor/group'

module Berkshelf
  class BaseGenerator < Thor::Group
    class << self
      def source_root
        Berkshelf.root.join('generator_files')
      end
    end

    # A list of cookbook patterns accepted by generators inheriting from
    # this generator.
    #
    # @return [Array<String>]
    PATTERNS = [
      "environment",
      "application",
      "library",
      "wrapper"
    ].freeze

    shell = Berkshelf.ui

    argument :path,
      type: :string,
      required: true

    class_option :pattern,
      type: :string,
      default: "application",
      desc: "Modifies the generated skeleton based on the given pattern.",
      aliases: "-p",
      enum: BaseGenerator::PATTERNS

    include Thor::Actions

    private

      def target
        @target ||= Pathname.new(File.expand_path(path))
      end
  end
end
