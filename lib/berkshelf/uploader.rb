require "chef/cookbook/chefignore"
require "chef/cookbook/cookbook_version_loader"
require "chef/cookbook_uploader"
require "chef/exceptions"

module Berkshelf
  class Uploader
    attr_reader :berksfile
    attr_reader :lockfile
    attr_reader :options
    attr_reader :names

    def initialize(berksfile, *args)
      @berksfile = berksfile
      @lockfile  = berksfile.lockfile
      opts       = args.last.respond_to?(:to_hash) ? args.pop.to_hash.each_with_object({}) { |(k, v), m| m[k.to_sym] = v } : {}

      @options = {
        force: false,
        freeze: true,
        halt_on_frozen: false,
        validate: true,
      }.merge(opts)

      @names = Array(args).flatten
    end

    def run
      Berkshelf.log.info "Uploading cookbooks"

      cookbooks = if names.empty?
                    Berkshelf.log.debug "  No names given, using all cookbooks"
                    filtered_cookbooks
                  else
                    Berkshelf.log.debug "  Names given (#{names.join(", ")})"
                    names.map { |name| lockfile.retrieve(name) }
                  end

      # Perform all validations first to prevent partially uploaded cookbooks
      Validator.validate_files(cookbooks)

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
        # this is a hack to work around a bug in chef 13.0-13.2 protocol negotiation on POST requests, its only
        # use is to force protocol negotiation via a GET request -- it doesn't matter if it 404s.  once we do not
        # support those early 13.x versions this line can be safely deleted.
        connection.get("users/#{Berkshelf.config.chef.node_name}") rescue nil

        cookbooks.map do |cookbook|
          begin
            compiled_metadata = cookbook.compile_metadata
            cookbook.reload if compiled_metadata
            cookbook_version = cookbook.cookbook_version
            Berkshelf.log.debug "  Uploading #{cookbook.cookbook_name}"
            cookbook_version.freeze_version if options[:freeze]

            # another two lines that are necessary for chef < 13.2 support (affects 11.x/12.x as well)
            cookbook_version.metadata.maintainer "" if cookbook_version.metadata.maintainer.nil?
            cookbook_version.metadata.maintainer_email "" if cookbook_version.metadata.maintainer_email.nil?

            begin
              Chef::CookbookUploader.new(
                [ cookbook_version ],
                force: options[:force],
                concurrency: 1, # sadly
                rest: connection,
                skip_syntax_check: options[:skip_syntax_check]
              ).upload_cookbooks
              Berkshelf.formatter.uploaded(cookbook, connection)
            rescue Chef::Exceptions::CookbookFrozen
              if options[:halt_on_frozen]
                raise FrozenCookbook.new(cookbook)
              end

              Berkshelf.formatter.skipping(cookbook, connection)
            end
          ensure
            if compiled_metadata
              # this is necessary on windows to clean up the ruby object that was pointing at the file
              # so that we can reliably delete it.  windows is terrible.
              GC.start
              File.unlink(compiled_metadata)
            end
          end
        end
      end
    end

    # Lookup dependencies in a cookbook and iterate to return dependencies of dependencies.
    #
    # This method is recursive. It iterates over a cookbook's dependencies
    # and their dependencies in order to return an array of cookbooks, starting
    # with the cookbook passed and followed by it's dependencies.
    #
    # @return [Array<CachedCookbook>]
    #
    def lookup_dependencies(cookbook, checked = {})
      Berkshelf.log.debug "  Looking up dependencies for #{cookbook}"

      dependencies = []

      lockfile.graph.find(cookbook).dependencies.each do |name, _|
        next if checked[name]

        # break cyclic graphs
        checked[name] = true

        # this is your standard depth-first tree traversal with the deps first...
        dependencies += lookup_dependencies(name, checked)
        # ..then the node itself
        dependencies << name
      end
      dependencies
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
      dependencies = berksfile.dependencies.map(&:name)

      checked = {}
      cookbook_order = dependencies.map do |dependency|
        # for each dep add all its deps first, then the dep itself
        lookup_dependencies(dependency, checked) + [ dependency ]
      end.flatten

      cookbook_order.uniq.map { |dependency| lockfile.retrieve(dependency) }
    end
  end
end
