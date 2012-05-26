module KnifeCookbookDependencies
  class Cookbook
    module Common
      module Path

        def full_path
          File.join(cookbook.unpacked_cookbook_path, cookbook.name)
        end

        def clean(location)
          FileUtils.rm_rf location
          FileUtils.rm_f cookbook.download_filename
        end

      end

      module Prepare
        def prepare
          cookbook.add_version_constraint("= #{cookbook.version_from_metadata.to_s}")
        end
      end

      module Unpack
        def unpack(location, options)
          return true
        end
      end

      module Version
        def latest_constrained_version
          cookbook.version_from_metadata
        end

        def versions
          [cookbook.version_from_metadata]
        end
      end
    end
  end
end
