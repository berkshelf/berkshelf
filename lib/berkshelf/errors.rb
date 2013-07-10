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

  class InternalError < BerkshelfError; status_code(99); end
  class ArgumentError < InternalError; end
  class AbstractFunction < InternalError
    def to_s
      'Function must be implemented on includer'
    end
  end

  class BerksfileNotFound < BerkshelfError
    status_code(100)

    # @param [#to_s] filepath
    #   the path where a Berksfile was not found
    def initialize(filepath)
      @filepath = File.dirname(File.expand_path(filepath)) rescue filepath
    end

    def to_s
      "No Berksfile or Berksfile.lock found at '#{@filepath}'!"
    end
  end

  class NoVersionForConstraints < BerkshelfError; status_code(101); end
  class DuplicateLocationDefined < BerkshelfError; status_code(102); end
  class CookbookNotFound < BerkshelfError; status_code(103); end
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

  class DuplicateSourceDefined < BerkshelfError; status_code(105); end
  class NoSolution < BerkshelfError; status_code(106); end
  class CookbookSyntaxError < BerkshelfError; status_code(107); end

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

  class GitNotFound < BerkshelfError
    status_code(110)

    def to_s
      'Could not find a Git executable in your path - please add it and try again'
    end
  end

  class ConstraintNotSatisfied < BerkshelfError; status_code(111); end
  class InvalidChefAPILocation < BerkshelfError; status_code(112); end
  class BerksfileReadError < BerkshelfError
    # @param [#status_code] original_error
    def initialize(original_error)
      @original_error  = original_error
      @error_message   = original_error.to_s
      @error_backtrace = original_error.backtrace
    end

    status_code(113)

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

    # @param [Berkshelf::Location] location
    #   the location that is mismatched
    # @param [Berkshelf::CachedCookbook] cached_cookbook
    #   the cached_cookbook that is mismatched
    def initialize(location, cached_cookbook)
      @location = location
      @cached_cookbook = cached_cookbook
    end

    def to_s
      [
        "In your Berksfile, you have:",
        "",
        "  cookbook '#{@location.name}'",
        "",
        "But that cookbook is actually named '#{@cached_cookbook.cookbook_name}'",
        "",
        "This can cause potentially unwanted side-effects in the future",
        "",
        "NOTE: If you don't explicitly set the `name` attribute in the metadata, the name of the directory will be used!",
      ].join("\n")
    end
  end

  class InvalidConfiguration < BerkshelfError
    status_code(115)

    def initialize(errors)
      @errors = errors
    end

    def to_s
      [
        'Invalid configuration:',
        @errors.map { |key, errors| errors.map { |error| "  #{key} #{error}" } },
      ].join("\n")
    end
  end

  class ConfigExists < BerkshelfError; status_code(116); end
  class ConfigurationError < BerkshelfError; status_code(117); end
  class InsufficientPrivledges < BerkshelfError; status_code(119); end
  class ExplicitCookbookNotFound < BerkshelfError; status_code(120); end
  class ValidationFailed < BerkshelfError; status_code(121); end
  class InvalidVersionConstraint < BerkshelfError; status_code(122); end
  class CommunitySiteError < BerkshelfError; status_code(123); end

  class CookbookValidationFailure < BerkshelfError
    status_code(124)

    # @param [Berkshelf::Location] location
    #   the location (or any subclass) raising this validation error
    # @param [Berkshelf::CachedCookbook] cached_cookbook
    #   the cached_cookbook that does not satisfy the constraint
    def initialize(location, cached_cookbook)
      @location = location
      @cached_cookbook = cached_cookbook
    end

    def to_s
      [
        "The cookbook downloaded from #{@location.to_s}:",
        "  #{@cached_cookbook.cookbook_name} (#{@cached_cookbook.version})",
        "",
        "does not satisfy the version constraint:",
        "  #{@cached_cookbook.cookbook_name} (#{@location.version_constraint})",
        "",
        "This occurs when the Chef Server has a cookbook with a missing/mis-matched version number in its `metadata.rb`",
      ].join("\n")
    end
  end

  class ClientKeyFileNotFound < BerkshelfError; status_code(125); end

  class UploadFailure < BerkshelfError; end
  class FrozenCookbook < UploadFailure; status_code(126); end
  class InvalidSiteShortnameError < BerkshelfError
    status_code(127)

    # @param [String,Symbol] shortname
    #   the shortname for the site (see SiteLocation::SHORTNAMES)
    def initialize(shortname)
      @shortname = shortname
    end

    def to_s
      [
        "Unknown site shortname '#{@shortname}' - supported shortnames are:",
        "",
        "  * " + SiteLocation::SHORTNAMES.keys.join("\n  * "),
      ].join("\n")
    end
  end

  class OutdatedCookbookSource < BerkshelfError
    status_code(128)

    # @param [Berkshelf::CookbookSource] source
    #   the cookbook source that is outdated
    def initialize(locked_source, source)
      @locked_source = locked_source
      @source = source
    end

    def to_s
      [
        "Berkshelf could not find compatible versions for cookbook '#{@source.name}':",
        "  In Berksfile:",
        "    #{@source.name} (#{@source.version_constraint})",
        "",
        "  In Berksfile.lock:",
        "    #{@locked_source.name} (#{@locked_source.locked_version})",
        "",
        "Try running `berks update #{@source.name}, which will try to find  '#{@source.name}' matching '#{@source.version_constraint}'.",
      ].join("\n")
    end
  end

  class EnvironmentNotFound < BerkshelfError
    status_code(129)

    def initialize(environment_name)
      @environment_name = environment_name
    end

    def to_s
      "The environment '#{@environment_name}' does not exist"
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
      "The file at '#{@destination}' is not a known compression type"
    end
  end

  # Raised when a cookbook or its recipes contain a space or invalid
  # character in the path.
  #
  # @param [Berkshelf::CachedCookbook] cookbook
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

  # Raised when a CachedCookbook has a license file that isn't allowed
  # by the Berksfile.
  #
  # @param [Berkshelf::CachedCookbook] cookbook
  #   the cookbook that failed license validation
  class LicenseNotAllowed < BerkshelfError
    status_code(133)

    def initialize(cookbook)
      @cookbook = cookbook
    end

    def to_s
      msg =  "'#{@cookbook.cookbook_name}' has a license of '#{@cookbook.metadata.license}', but"
      msg << " '#{@cookbook.metadata.license}' is not in your list of allowed licenses"
      msg
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
      "Available licenses: #{Berkshelf::CookbookGenerator::LICENSES.join(', ')}"
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
    def initialize(lockfile, original)
      @lockfile = Pathname.new(lockfile.to_s).basename.to_s
      @original = original
    end

    def to_s
      "Error reading the Berkshelf lockfile `#{@lockfile}` (#{@original.class})"
    end
  end
end
