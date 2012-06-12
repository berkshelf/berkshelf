module KnifeCookbookDependencies
  class Cookbookfile
    include DSL

    class << self
      def from_file(file)
        content = File.read(file)
        read(content)
      rescue Errno::ENOENT => e
        raise CookbookfileNotFound, "No Cookbookfile or Cookbookfile.lock found at: #{file}."
      end

      def read(content)
        object = new
        object.instance_eval(content)

        object
      end
    end

    def initialize
      @sources = Hash.new
    end

    def add_source(source)
      raise DuplicateSourceDefined if has_source?(source)
      @sources[source.to_s] = source
    end

    def remove_source(source)
      @sources.delete(source.to_s)
    end

    def has_source?(source)
      @sources.has_key?(source.to_s)
    end

    def sources
      @sources.collect { |name, source| source }.flatten
    end

    def groups
      {}.tap do |groups|
        @sources.each_pair do |name, source|
          source.groups.each do |group|
            groups[group] ||= []
            groups[group] << source
          end
        end
      end
    end

    # @param [String] name
    #   name of the source to return
    def [](name)
      @sources[name]
    end
    alias_method :get_source, :[]

    def install(options = {})
      if File.exist?(KCD::Lockfile::DEFAULT_FILENAME)
        filename = KCD::Lockfile::DEFAULT_FILENAME
        lockfile = true
      else
        filename = KCD::DEFAULT_FILENAME
        lockfile = false
      end

      l_sources = if options[:without]
        filter_sources(options[:without])
      else
        sources
      end

      resolver = Resolver.new(KCD.downloader, l_sources)
      resolver.resolve
      write_lockfile(resolver.sources) unless lockfile

      true
    end

    def upload(chef_server_url, options = {})
      l_sources = if options[:without]
        filter_sources(options[:without])
      else
        sources
      end

      resolver = Resolver.new(KCD.downloader, l_sources)
      cookbooks = resolver.resolve

      uploader = Uploader.new(cookbook_store, chef_server_url)

      cookbooks.each do |name, version|
        KCD.ui.info "Uploading #{name} (#{version}) to: #{chef_server_url}"
        uploader.upload!(name, version)
      end
    end

    private

      def filter_sources(excluded)
        excluded.collect!(&:to_sym)
        sources.select do |source|
          (excluded & source.groups).empty?
        end
      end

      def write_lockfile(sources)
        KCD::Lockfile.new(sources).write
      end
  end
end
