# frozen_string_literal: true

require "yaml"
require "pathname"

module SaxonC
  module Libs
    # Loads the releases.yml describing where to download platform release.
    class Releases
      attr_reader :saxon_version, :saxon_edition

      def initialize(saxon_edition = :he)
        @saxon_edition = saxon_edition.to_sym
      end

      def archive_for(platform_key)
        data = releases_data
        data_for_edition = data.fetch(saxon_edition) do
          raise KeyError, "No release defined for Saxon edition #{saxon_edition} in #{release_path}"
        end
        data_for_edition.fetch(platform_key) do
          raise KeyError, "No archive defined for #{platform_key} in #{release_path}"
        end
      end

      def version
        @saxon_version ||= releases_data.fetch("version")
      end

      private

      def releases_data
        @releases_data ||= begin
          unless releases_path.exist?
            raise IOError, "Missing releases: #{releases_path}"
          end

          YAML.load_file(releases_path)
        end
      end

      def releases_path
        Pathname.new(__dir__).join("..", "..", "..", "releases.yml").expand_path
      end
    end
  end
end
