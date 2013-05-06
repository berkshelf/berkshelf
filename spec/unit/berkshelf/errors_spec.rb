require 'spec_helper'

shared_examples "errors" do
  it "should respond to #status_code" do
    -> { 
      arity = described_class.instance_method(:initialize).arity
      if arity > 0
        args = ["test argument"] * arity
        described_class.new(*args).status_code
      else
        described_class.new.status_code
      end
    }.should_not raise_error
  end

  it "should respond to ::status_code" do
    -> { described_class.status_code }.should_not raise_error
  end
end

status_codes = [Berkshelf::BerkshelfError,
                Berkshelf::InternalError,
                Berkshelf::ArgumentError,
                Berkshelf::AbstractFunction,
                Berkshelf::BerksfileNotFound,
                Berkshelf::NoVersionForConstraints,
                Berkshelf::DuplicateLocationDefined,
                Berkshelf::CookbookNotFound,
                Berkshelf::GitError,
                Berkshelf::PrivateGitRepo,
                Berkshelf::AmbiguousGitRef,
                Berkshelf::InvalidGitRef,
                Berkshelf::DuplicateSourceDefined,
                Berkshelf::NoSolution,
                Berkshelf::CookbookSyntaxError,
                Berkshelf::BerksConfigNotFound,
                Berkshelf::InvalidGitURI,
                Berkshelf::UnknownGitHubProtocol,
                Berkshelf::GitNotFound,
                Berkshelf::ConstraintNotSatisfied,
                Berkshelf::InvalidChefAPILocation,
                Berkshelf::BerksfileReadError,
                Berkshelf::AmbiguousCookbookName,
                Berkshelf::InvalidConfiguration,
                Berkshelf::ConfigExists,
                Berkshelf::ConfigurationError,
                Berkshelf::CommandUnsuccessful,
                Berkshelf::InsufficientPrivledges,
                Berkshelf::ExplicitCookbookNotFound,
                Berkshelf::ValidationFailed,
                Berkshelf::InvalidVersionConstraint,
                Berkshelf::CommunitySiteError,
                Berkshelf::CookbookValidationFailure,
                Berkshelf::ClientKeyFileNotFound,
                Berkshelf::UploadFailure,
                Berkshelf::InvalidSiteShortnameError].collect do |error_class|
  describe error_class do
    include_examples "errors"
  end

  error_class.status_code
end

describe Berkshelf::BerkshelfError do
  status_codes.sort!
  previous_status_code = nil
  until status_codes.empty? do
    status_code = status_codes.shift
    next if status_code == Berkshelf::BerkshelfError::DEFAULT_STATUS_CODE
    it "should not repeat the status code #{status_code}" do
      status_code.should_not == previous_status_code
    end
    previous_status_code = status_codes.shift
  end
end
