module Berkshelf
  class Uploader
    attr_reader :berksfile
    attr_reader :lockfile
    attr_reader :options
    attr_reader :names

    def initialize(berksfile, *args)
      @berksfile = berksfile
      @lockfile  = berksfile.lockfile

      @options = {
        force:          false,
        freeze:         true,
        halt_on_frozen: false,
        validate:       true,
      }.merge(args.last.is_a?(Hash) ? args.pop : {})

      @names = Array(args).flatten
    end

    def run
      Berkshelf.log.info "Uploading cookbooks"

      cookbooks = if names.empty?
                    Berkshelf.log.debug "  No names given, using all cookbooks"
                    filtered_cookbooks
                  else
                    Berkshelf.log.debug "  Names given (#{names.join(', ')})"
                    names.map { |name| lockfile.retrieve(name) }
                  end

      # Perform all validations first to prevent partially uploaded cookbooks
      cookbooks.each { |cookbook| validate_files!(cookbook) }

      upload(cookbooks)
      cookbooks
    end

    private

      # Upload the list of cookbooks to the Chef Server, with some exception
      # wrapping.
      #
      # @param [Array<String>] cookbooks
      def upload(cookbooks)
        Berkshelf.log.info "Starting upload"

        Berkshelf.ridley_connection(options) do |connection|
          cookbooks.each do |cookbook|
            Berkshelf.log.debug "  Uploading #{cookbook}"

            begin
              connection.cookbook.upload(cookbook.path,
                name:     cookbook.cookbook_name,
                force:    options[:force],
                freeze:   options[:freeze],
                validate: options[:validate],
              )

              Berkshelf.formatter.uploaded(cookbook, connection)
            rescue Ridley::Errors::FrozenCookbook
              if options[:halt_on_frozen]
                raise FrozenCookbook.new(cookbook)
              end

              Berkshelf.formatter.skipping(cookbook, connection)
            end
          end
        end
      end

      # Filter cookbooks based off the list of dependencies in the Berksfile.
      #
      # This method is secretly recursive. It iterates over each dependency in
      # the Berksfile (using {Berksfile#dependencies} to account for filters)
      # and retrieves that cookbook, it's dependencies, and the recusive
      # dependencies, but iteratively.
      #
      # @return [Array<CachedCookbook>]
      #
      def filtered_cookbooks
        # Create a copy of the dependencies. We need to make a copy, or else
        # we would be adding dependencies directly to the Berksfile object, and
        # that would be a bad idea...
        dependencies = Array(berksfile.dependencies)

        berksfile.dependencies.inject({}) do |hash, dependency|
          # Skip dependencies that are already added
          next if hash[dependency.name]

          lockfile.graph.find(dependency).dependencies.each do |name, dependency|
            hash[name] ||= lockfile.retrieve(name)
            dependencies << dependency
          end

          hash[dependency.name] = lockfile.retrieve(dependency)

          hash
        end.values
      end

      # Validate that the given cookbook does not have "bad" files. Currently
      # this means including spaces in filenames (such as recipes)
      #
      # @param [CachedCookbook] cookbook
      #  the Cookbook to validate
      def validate_files!(cookbook)
        path = cookbook.path.to_s

        files = Dir.glob(File.join(path, '**', '*.rb')).select do |f|
          parent = Pathname.new(path).dirname.to_s
          f.gsub(parent, '') =~ /[[:space:]]/
        end

        raise InvalidCookbookFiles.new(cookbook, files) unless files.empty?
      end
  end
end
