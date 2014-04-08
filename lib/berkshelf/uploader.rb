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
                    lockfile.graph.locks.map { |_, lock| lockfile.retrieve(lock) }
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
