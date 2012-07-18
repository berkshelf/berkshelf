module Berkshelf
  # @author Jamie Winsor <jamie@vialstudios.com>
  class InitGenerator < BaseGenerator
    argument :path,
      type: :string,
      required: true

    class_option :metadata_entry,
      type: :boolean,
      default: false

    class_option :chefignore,
      type: :boolean,
      default: false

    class_option :vagrant,
      type: :boolean,
      default: false

    class_option :git,
      type: :boolean,
      default: false

    class_option :thor,
      type: :boolean,
      default: false

    class_option :no_bundler,
      type: :boolean,
      default: false

    def generate
      template "Berksfile.erb", target.join("Berksfile")

      if options[:chefignore]
        copy_file "chefignore", target.join("chefignore")
      end

      if options[:vagrant]
        create_file target.join("Vagrantfile")
      end

      if options[:git]
        copy_file "gitignore", target.join(".gitignore")
      end

      if options[:thor]
        copy_file "Thorfile", target.join("Thorfile")
      end

      unless options[:no_bundler]
        copy_file "Gemfile", target.join("Gemfile")
      end
    end
  end
end
