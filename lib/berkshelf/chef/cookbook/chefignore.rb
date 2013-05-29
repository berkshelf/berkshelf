module Berkshelf::Chef::Cookbook
  # Borrowed and modified from: {https://raw.github.com/opscode/chef/11.4.0/lib/chef/cookbook/chefignore.rb}
  #
  # Copyright:: Copyright (c) 2011 Opscode, Inc.
  #
  # Licensed under the Apache License, Version 2.0 (the "License");
  # you may not use this file except in compliance with the License.
  # You may obtain a copy of the License at
  #
  #     http://www.apache.org/licenses/LICENSE-2.0
  #
  # Unless required by applicable law or agreed to in writing, software
  # distributed under the License is distributed on an "AS IS" BASIS,
  # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  # See the License for the specific language governing permissions and
  # limitations under the License.
  class Chefignore
    class << self
      # Traverse a path in relative context to find a Chefignore file
      #
      # @param [String] path
      #   path to traverse
      #
      # @return [String, nil]
      def find_relative_to(path)
        [
          File.join(path, Berkshelf::Chef::Cookbook::Chefignore::FILENAME),
          File.join(path, 'cookbooks', Berkshelf::Chef::Cookbook::Chefignore::FILENAME)
        ].find { |f| File.exists?(f) }
      end
    end

    FILENAME                = 'chefignore'.freeze
    COMMENTS_AND_WHITESPACE = /^\s*(?:#.*)?$/

    attr_reader :ignores

    def initialize(ignore_file_or_repo)
      @ignore_file = find_ignore_file(ignore_file_or_repo)
      @ignores     = parse_ignore_file
    end

    def remove_ignores_from(file_list)
      Array(file_list).inject([]) do |unignored, file|
        ignored?(file) ? unignored : unignored << file
      end
    end

    def ignored?(file_name)
      @ignores.any? {|glob| File.fnmatch?(glob, file_name)}
    end

    private

      def parse_ignore_file
        ignore_globs = []
        if File.exist?(@ignore_file) && File.readable?(@ignore_file)
          File.foreach(@ignore_file) do |line|
            ignore_globs << line.strip unless line =~ COMMENTS_AND_WHITESPACE
          end
        else
          # Log a warning when Berkshelf gets a logger
        end
        ignore_globs
      end

      def find_ignore_file(path)
        if File.basename(path) =~ /#{FILENAME}/
          path
        else
          File.join(path, FILENAME)
        end
      end
  end
end
