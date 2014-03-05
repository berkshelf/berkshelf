module Berkshelf
  class BerkshelfError < StandardError
    class << self
      # @param [Integer] code
      def status_code(code)
        define_method(:status_code) { code }
        define_singleton_method(:status_code) { code }
      end
    end

    alias_method :message, :to_s
  end

  class DeprecatedError < BerkshelfError; status_code(10); end
  class InternalError < BerkshelfError; status_code(99); end
  class ArgumentError < InternalError; end
  class AbstractFunction < InternalError; end

  class BerksfileNotFound < BerkshelfError
    status_code(100)

    # @param [#to_s] filepath
    #   the path where a Berksfile was not found
    def initialize(filepath)
      @filepath = File.dirname(File.expand_path(filepath)) rescue filepath
    end

    def to_s
      "No Berksfile or Berksfile.lock found at `#{@filepath}'!"
    end
  end

  class CookbookNotFound < BerkshelfError
    status_code(103)

    def initialize(name, version, location)
      @name     = name
      @version  = version
      @location = location
    end

    def to_s
      if @version
        "Cookbook '#{@name}' (#{@version}) not found #{@location}!"
      else
        "Cookbook '#{@name}' not found #{@location}!"
      end
    end
  end

  class GitError < BerkshelfError
    status_code(104)

    # @param [#to_s] stderr
    #   the error that came from stderr
    def initialize(stderr)
      @stderr = stderr.to_s
    end

    # A common header for all git errors. The #to_s method should
    # use this before outputting any specific errors.
    #
    # @return [String]
    def header
      'An error occurred during Git execution:'
    end

    def to_s
      [
        header,
        "",
        "  " + @stderr.to_s.split("\n").map(&:strip).join("\n  "),
        ""
      ].join("\n")
    end
  end

  class AmbiguousGitRef < GitError
    def initialize(ref)
      @ref = ref
    end

    def to_s
      [
        header,
        "",
        "  Ambiguous Git ref: '#{@ref}'",
        "",
      ].join("\n")
    end
  end

  class InvalidGitRef < GitError
    def initialize(ref)
      @ref = ref
    end

    def to_s
      [
        header,
        "",
        "  Invalid Git ref: '#{@ref}'",
        "",
      ].join("\n")
    end
  end

  class DuplicateDependencyDefined < BerkshelfError
    status_code(105)

    def initialize(name)
      @name = name
    end

    def to_s
      "Your Berksfile contains multiple entries named '#{@name}'. Please " \
      "remove duplicate dependencies, or put them in different groups."
    end
  end

  class NoSolutionError < BerkshelfError
    status_code(106)

    attr_reader :demands

    # @param [Array<Dependency>] demands
    def initialize(demands)
      @demands = demands
    end

    def to_s
      "Unable to find a solution for demands: #{demands.join(', ')}"
    end
  end

  class MercurialError < BerkshelfError
    status_code(108);
  end

  class InvalidHgURI < BerkshelfError
    status_code(110)

    # @param [String] uri
    def initialize(uri)
      @uri = uri
    end

    def to_s
      "'#{@uri}' is not a valid Mercurial URI"
    end
  end

  class InvalidGitURI < BerkshelfError
    status_code(110)

    # @param [String] uri
    def initialize(uri)
      @uri = uri
    end

    def to_s
      "'#{@uri}' is not a valid Git URI"
    end
  end

  class InvalidGitHubIdentifier < BerkshelfError
    status_code(110)

    # @param [String] repo_identifier
    def initialize(repo_identifier)
      @repo_identifier = repo_identifier
    end

    def to_s
      "'#{@repo_identifier}' is not a valid GitHub identifier - should not end in '.git'"
    end
  end

  class UnknownGitHubProtocol < BerkshelfError
    status_code(110)

    # @param [String] protocol
    def initialize(protocol)
      @protocol = protocol
    end

    def to_s
      "'#{@protocol}' is not supported for the 'github' location key - please use 'git' instead"
    end
  end

  class MercurialNotFound < BerkshelfError
    status_code(111)

    def to_s
      'Could not find a Mercurial executable in your path - please add it and try again'
    end
  end

  class GitNotFound < BerkshelfError
    status_code(110)

    def to_s
      'Could not find a Git executable in your path - please add it and try again'
    end
  end

  class BerksfileReadError < BerkshelfError
    status_code(113)

    # @param [#status_code] original_error
    def initialize(original_error)
      @original_error  = original_error
      @error_message   = original_error.to_s
      @error_backtrace = original_error.backtrace
    end

    def status_code
      @original_error.respond_to?(:status_code) ? @original_error.status_code : 113
    end

    alias_method :original_backtrace, :backtrace
    def backtrace
      Array(@error_backtrace) + Array(original_backtrace)
    end

    def to_s
      [
        "An error occurred while reading the Berksfile:",
        "",
        "  #{@error_message}",
      ].join("\n")
    end
  end

  class MismatchedCookbookName < BerkshelfError
    status_code(114)

    # @param [Dependency] dependency
    #   the dependency with the expected name
    # @param [CachedCookbook] cached_cookbook
    #   the cached_cookbook with the mismatched name
    def initialize(dependency, cached_cookbook)
      @dependency      = dependency
      @cached_cookbook = cached_cookbook
    end

    def to_s
      out =  "In your Berksfile, you have:\n"
      out << "\n"
      out << "  cookbook '#{@dependency.name}'\n"
      out << "\n"
      out << "But that cookbook is actually named '#{@cached_cookbook.cookbook_name}'\n"
      out << "\n"
      out << "This can cause potentially unwanted side-effects in the future.\n"
      out << "\n"
      out << "NOTE: If you do not explicitly set the `name' attribute in the "
      out << "metadata, the name of the directory will be used instead. This "
      out << "is often a cause of confusion for dependency solving."
      out
    end
  end

  class InvalidConfiguration < BerkshelfError
    status_code(115)

    def initialize(errors)
      @errors = errors
    end

    def to_s
      out = "Invalid configuration:\n"
      @errors.each do |key, errors|
        errors.each do |error|
          out << "  #{key} #{error}\n"
        end
      end

      out.strip
    end
  end

  class InsufficientPrivledges < BerkshelfError
    status_code(119)

    def initialize(path)
      @path = path
    end

    def to_s
      "You do not have permission to write to `#{@path}'! Please chown the " \
      "path to the current user, chmod the permissions to include the " \
      "user, or choose a different path."
    end
  end

  class DependencyNotFound < BerkshelfError
    status_code(120)

    # @param [String, Array<String>] names
    #   the list of cookbook names that were not defined
    def initialize(names)
      @names = Array(names)
    end

    def to_s
      if @names.size == 1
        "Dependency '#{@names.first}' was not found. Please make sure it is " \
        "in your Berksfile, and then run `berks install' to download and " \
        "install the missing dependencies."
      else
        out = "The following dependencies were not found:\n"
        @names.each do |name|
          out << "  * #{name}\n"
        end
        out << "\n"
        out << "Please make sure they are in your Berksfile, and then run "
        out << "`berks install' to download and install the missing "
        out << "dependencies."
        out
      end
    end
  end

  class CommunitySiteError < BerkshelfError
    status_code(123)

    def initialize(uri, message)
      @uri     = uri
      @message = message
    end

    def to_s
      "An unexpected error occurred retrieving #{@message} from the cookbook " \
      "site at `#{@api_uri}'."
    end
  end

  class CookbookValidationFailure < BerkshelfError
    status_code(124)

    # @param [Location] location
    #   the location (or any subclass) raising this validation error
    # @param [CachedCookbook] cached_cookbook
    #   the cached_cookbook that does not satisfy the constraint
    def initialize(dependency, cached_cookbook)
      @dependency      = dependency
      @cached_cookbook = cached_cookbook
    end

    def to_s
      "The cookbook downloaded for #{@dependency} did not satisfy the constraint."
    end
  end

  class UploadFailure < BerkshelfError; end
  class FrozenCookbook < UploadFailure
    status_code(126)

    # @param [CachedCookbook] cookbook
    def initialize(cookbook)
      @cookbook = cookbook
    end

    def to_s
      "The cookbook #{@cookbook.cookbook_name} (#{@cookbook.version}) " \
      "already exists and is frozen on the Chef Server. Use the --force " \
      "option to override."
    end
  end

  class OutdatedDependency < BerkshelfError
    status_code(128)

    # @param [Dependency] locked_dependency
    #   the locked dependency
    # @param [Dependency] dependency
    #   the dependency that is outdated
    def initialize(locked, dependency)
      @locked     = locked
      @dependency = dependency
    end

    def to_s
      "Berkshelf could not find compatible versions for cookbook '#{@dependency.name}':\n" +
      "  In Berksfile:\n" +
      "    #{@dependency.name} (#{@dependency.version_constraint})\n\n" +
      "  In Berksfile.lock:\n" +
      "    #{@locked.name} (#{@locked.version})\n\n" +
      "Try running `berks update #{@dependency.name}`, which will try to find '#{@dependency.name}' matching " +
        "'#{@dependency.version_constraint}'."
    end
  end

  class EnvironmentNotFound < BerkshelfError
    status_code(129)

    def initialize(environment_name)
      @environment_name = environment_name
    end

    def to_s
      "The environment `#{@environment_name}' does not exist"
    end
  end

  class ChefConnectionError < BerkshelfError
    status_code(130)

    def to_s
      'There was an error connecting to the Chef Server'
    end
  end

  class UnknownCompressionType < BerkshelfError
    status_code(131)

    def initialize(destination)
      @destination = destination
    end

    def to_s
      "The file at `#{@destination}' is not a known compression type"
    end
  end

  # Raised when a cookbook or its recipes contain a space or invalid
  # character in the path.
  #
  # @param [CachedCookbook] cookbook
  #   the cookbook that failed validation
  # @param [Array<#to_s>] files
  #   the list of files that were not valid
  class InvalidCookbookFiles < BerkshelfError
    status_code(132)

    def initialize(cookbook, files)
      @cookbook = cookbook
      @files = files
    end

    def to_s
      [
        "The cookbook '#{@cookbook.cookbook_name}' has invalid filenames:",
        "",
        "  " + @files.map(&:to_s).join("\n  "),
        "",
        "Please note, spaces are not a valid character in filenames",
      ].join("\n")
    end
  end

  class LicenseNotFound < BerkshelfError
    status_code(134)

    attr_reader :license

    def initialize(license)
      @license = license
    end

    def to_s
      "Unknown license: '#{license}'\n" +
      "Available licenses: #{CookbookGenerator::LICENSES.join(', ')}"
    end
  end

  # Raised when a cookbook or its recipes contain a space or invalid
  # character in the path.
  class ConfigNotFound < BerkshelfError
    status_code(135)

    # @param [String] type
    #   the type of config that was not found (Berkshelf, Chef, etc)
    # @param [#to_s] path
    #   the path to the specified Chef config that did not exist
    def initialize(type, path)
      @type = type.to_s
      @path = path
    end

    def to_s
      "No #{@type.capitalize} config file found at: '#{@path}'!"
    end
  end

  class LockfileParserError < BerkshelfError
    status_code(136)

    # @param [String] lockfile
    #   the path to the Lockfile
    # @param [~Exception] original
    #   the original exception class
    def initialize(original)
      @original = original
    end

    def to_s
      "Error reading the Berkshelf lockfile:\n\n" \
      "  #{@original.class}: #{@original.message}"
    end
  end

  class InvalidSourceURI < BerkshelfError
    status_code(137)

    def initialize(url, reason = nil)
      @url    = url
      @reason = reason
    end

    def to_s
      msg =  "'#{@url}' is not a valid Berkshelf source URI."
      msg << " #{@reason}." unless @reason.nil?
      msg
    end
  end

  class DuplicateDemand < BerkshelfError; status_code(138); end
  class VendorError < BerkshelfError; status_code(139); end
  class LockfileNotFound < BerkshelfError
    status_code(140)

    def to_s
      'Lockfile not found! Run `berks install` to create the lockfile.'
    end
  end

  class NotACookbook < BerkshelfError
    status_code(141)

    # @param [String] path
    #   the path to the thing that is not a cookbook
    def initialize(path)
      @path = File.expand_path(path) rescue path
    end

    def to_s
      "The resource at `#{@path}' does not appear to be a valid cookbook. " \
      "Does it have a metadata.rb?"
    end
  end

  class PackageError < BerkshelfError; status_code(143); end

  class LockfileOutOfSync < BerkshelfError
    status_code(144)

    def to_s
      'The lockfile is out of sync! Run `berks install` to sync the lockfile.'
    end
  end

  class DependencyNotInstalled < BerkshelfError
    status_code(145)

    def initialize(dependency)
      @name    = dependency.name
      @version = dependency.locked_version
    end

    def to_s
      "The cookbook '#{@name} (#{@version})' is not installed. Please run " \
      "`berks install` to download and install the missing dependency."
    end
  end

  class NoAPISourcesDefined < BerkshelfError
    status_code(146)

    def to_s
      "Your Berksfile does not define any API sources! You must define " \
      "at least one source in order to download cookbooks. To add the " \
      "default Berkshelf API server, add the following code to the top of " \
      "your Berksfile:" \
      "\n\n" \
      "    source 'https://api.berkshelf.com'"
    end
  end
end
