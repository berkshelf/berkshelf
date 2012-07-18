module Berkshelf
  # @author Jamie Winsor <jamie@vialstudios.com>
  class CookbookGenerator < BaseGenerator
    argument :name,
      type: :string,
      required: true

    argument :path,
      type: :string,
      required: true

    class_option :vagrant,
      type: :boolean,
      default: false

    class_option :git,
      type: :boolean,
      default: false

    class_option :foodcritic,
      type: :boolean,
      default: false

    class_option :no_bundler,
      type: :boolean,
      default: false

    def generate
      empty_directory target.join("files/default")
      empty_directory target.join("templates/default")
      empty_directory target.join("attributes")
      empty_directory target.join("definitions")
      empty_directory target.join("libraries")
      empty_directory target.join("providers")
      empty_directory target.join("recipes")
      empty_directory target.join("resources")
      
      create_file target.join("recipes/default.rb")
      create_file target.join("README.md")
      create_file target.join("metadata.rb")

      ::Berkshelf::InitGenerator.new([target], options.merge(default_options)).invoke_all
    end

    private

      def default_options
        { metadata_entry: true, chefignore: true, cookbook_name: name }
      end
  end
end
