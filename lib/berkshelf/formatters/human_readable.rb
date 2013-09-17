module Berkshelf
  module Formatters
    class HumanReadable
      include AbstractFormatter

      register_formatter :human

      # Output the version of Berkshelf
      def version
        Berkshelf.ui.info Berkshelf::VERSION
      end

      # @param [Berkshelf::Dependency] dependency
      def fetch(dependency)
        Berkshelf.ui.info "Fetching '#{dependency.name}' from #{dependency.location}"
      end

      # Output a Cookbook installation message using {Berkshelf.ui}
      #
      # @param [String] cookbook
      # @param [String] version
      # @param [Berkshelf::Dependency] dependency
      def install(cookbook, version, dependency)
        Berkshelf.ui.info "Installing #{cookbook} (#{version})"
      end

      # Output a Cookbook use message using {Berkshelf.ui}
      #
      # @param [String] cookbook
      # @param [String] version
      # @param [~Location] location
      def use(cookbook, version, location = nil)
        message = "Using #{cookbook} (#{version})"
        message += " #{location}" if location
        Berkshelf.ui.info message
      end

      # Output a Cookbook upload message using {Berkshelf.ui}
      #
      # @param [Berkshelf::CachedCookbook] cookbook
      # @param [Ridley::Connection] conn
      def upload(cookbook, conn)
        Berkshelf.ui.info "Uploading #{cookbook.cookbook_name} (#{cookbook.version}) to: '#{conn.server_url}'"
      end

      # Output a Cookbook skip message using {Berkshelf.ui}
      #
      # @param [Berkshelf::CachedCookbook] cookbook
      # @param [Ridley::Connection] conn
      def skip(cookbook, conn)
        Berkshelf.ui.info "Skipping #{cookbook.cookbook_name} (#{cookbook.version}) (already uploaded)"
      end

      # Output a list of outdated cookbooks and the most recent version
      # using {Berkshelf.ui}
      #
      # @param [Hash] hash
      #   the list of outdated cookbooks in the format
      #   { 'cookbook' => { 'api.berkshelf.com' => #<Cookbook> } }
      def outdated(hash)
        hash.keys.each do |name|
          hash[name].each do |source, newest|
            string = "  * #{newest.name} (#{newest.version})"
            unless Berksfile.default_sources.map { |s| s.uri.to_s }.include?(source)
              string << " [#{source}]"
            end
            Berkshelf.ui.info string
          end
        end
      end

      # Output a Cookbook package message using {Berkshelf.ui}
      #
      # @param [String] cookbook
      # @param [String] destination
      def package(cookbook, destination)
        Berkshelf.ui.info "Cookbook(s) packaged to #{destination}!"
      end

      # Output a list of cookbooks using {Berkshelf.ui}
      #
      # @param [Hash<Dependency, CachedCookbook>] list
      def list(list)
        if list.empty?
          Berkshelf.ui.info "There are no cookbooks installed by your Berksfile"
        else
          Berkshelf.ui.info "Cookbooks installed by your Berksfile:"
          list.each do |dependency, cookbook|
            Berkshelf.ui.info("  * #{cookbook.cookbook_name} (#{cookbook.version})")
          end
        end
      end

      # Output Cookbook info message using {Berkshelf.ui}
      #
      # @param [CachedCookbook] cookbook
      def show(cookbook)
        Berkshelf.ui.info(cookbook.pretty_print)
      end

      # Output Cookbook vendor info message using {Berkshelf.ui}
      #
      # @param [CachedCookbook] cookbook
      # @param [String] destination
      def vendor(cookbook, destination)
        cookbook_destination = File.join(destination, cookbook.cookbook_name)
        Berkshelf.ui.info "Vendoring #{cookbook.cookbook_name} (#{cookbook.version}) to #{cookbook_destination}"
      end

      # Output a generic message using {Berkshelf.ui}
      #
      # @param [String] message
      def msg(message)
        Berkshelf.ui.info message
      end

      # Output an error message using {Berkshelf.ui}
      #
      # @param [String] message
      def error(message)
        Berkshelf.ui.error message
      end

      # Output a deprecation warning
      #
      # @param [String] message
      def deprecation(message)
        Berkshelf.ui.info "DEPRECATED: #{message}"
      end
    end
  end
end
