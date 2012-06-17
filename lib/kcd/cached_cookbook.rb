require 'chef/checksum_cache'
require 'chef/cookbook/syntax_check'

module KnifeCookbookDependencies
  class CachedCookbook
    class << self
      def from_path(path)        
        matchdata = File.basename(path.to_s).match(DIRNAME_REGEXP)
        return nil if matchdata.nil?

        cached_name = matchdata[1]

        metadata = Chef::Cookbook::Metadata.new

        if path.join("metadata.rb").exist?
          metadata.from_file(path.join("metadata.rb").to_s)
        end

        new(cached_name, path, metadata)
      end

      def checksum(filepath)
        Chef::ChecksumCache.generate_md5_checksum_for_file(filepath)
      end
    end

    DIRNAME_REGEXP = /^(.+)-(\d+\.\d+\.\d+)$/
    CHEF_TYPE = "cookbook_version".freeze
    CHEF_JSON_CLASS = "Chef::CookbookVersion".freeze

    extend Forwardable

    attr_reader :path

    attr_reader :recipes
    attr_reader :definitions
    attr_reader :libraries
    attr_reader :attributes
    attr_reader :files
    attr_reader :templates
    attr_reader :resources
    attr_reader :providers
    attr_reader :root_files
    attr_reader :cookbook_name
    attr_reader :metadata

    def_delegators :@metadata, :version

    def initialize(name, path, metadata)
      @cookbook_name = name
      @path = path
      @metadata = metadata
      @cookbook_files = []

      @recipes = []
      @definitions = []
      @libraries = []
      @attributes = []
      @files = []
      @templates = []
      @resources = []
      @providers = []
      @root_files = []

      load_files
    end

    def name
      "#{cookbook_name}-#{version}"
    end

    def checksums
      {}.tap do |checksums|
        cookbook_files.each do |file|
          checksums[self.class.checksum(file)] = file
        end
      end
    end

    def manifest
      Mash.new(
        recipes: recipes,
        definitions: definitions,
        libraries: libraries,
        attributes: attributes,
        files: files,
        templates: templates,
        resources: resources,
        providers: providers,
        root_files: root_files
      )
    end

    # Validates that this instance of CachedCookbook points to a valid location on disk that
    # contains a cookbook which passes a Ruby and template syntax check. Raises an error if
    # these assertions are not true.
    #
    # @return [Boolean]
    #   returns true if Cookbook is valid
    def validate!
      raise CookbookNotFound, "No Cookbook found at: #{path}" unless path.exist?

      unless quietly { syntax_checker.validate_ruby_files }
        raise CookbookSyntaxError, "Invalid ruby files in cookbook: #{name} (#{version})."
      end
      unless quietly { syntax_checker.validate_templates }
        raise CookbookSyntaxError, "Invalid template files in cookbook: #{name} (#{version})."
      end

      true
    end

    def to_hash
      result = manifest.dup
      result['chef_type'] = 'cookbook_version'
      result['name'] = name
      result['cookbook_name'] = cookbook_name
      result['version'] = version
      result['metadata'] = metadata
      result.to_hash
    end

    def to_json(*a)
      result = self.to_hash
      result['json_class'] = chef_json_class
      result['frozen?'] = false
      result.to_json(*a)
    end

    private

      attr_reader :relative_path
      attr_reader :cookbook_files

      def chef_type
        CHEF_TYPE
      end

      def chef_json_class
        CHEF_JSON_CLASS
      end

      def syntax_checker
        @syntax_checker ||= Chef::Cookbook::SyntaxCheck.new(path.to_s)
      end

      def load_files
        load_shallow('attributes', '*.rb')
        load_shallow('definitions', '*.rb')
        load_shallow('recipes', '*.rb')
        load_shallow('libraries', '*.rb')
        load_recursively("templates", "*")
        load_recursively("files", "*")
        load_recursively("resources", "*.rb")
        load_recursively("providers", "*.rb")
        load_root
      end

      def load_root
        Dir.glob(path.join('*'), File::FNM_DOTMATCH).each do |file|
          next if File.directory?(file)
          @cookbook_files << file
        end
      end

      def load_recursively(category_dir, glob)
        file_spec = path.join(category_dir, '**', glob)
        Dir.glob(file_spec, File::FNM_DOTMATCH).each do |file|
          next if File.directory?(file)
          @cookbook_files << file
        end
      end

      def load_shallow(*path_glob)
        Dir[path.join(*path_glob)].each do |file|
          @cookbook_files << file
        end
      end
  end
end
