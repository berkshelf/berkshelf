module Berkshelf
  class CachedLocation < PathLocation
    set_location_key :cached

    # @param [#to_s] name
    # @param [Solve::Constraint] version_constraint
    # @param [Berkshelf::CachedCookbook] cached_cookbook
    # @param [Hash] options
    def initialize(name, version_constraint, cached_cookbook, options={})
      options[:path]     = cached_cookbook.path
      options[:metadata] = cached_cookbook.metadata
      super(name, version_constraint, options)
    end
  end
end
