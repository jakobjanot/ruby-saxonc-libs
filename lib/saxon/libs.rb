# frozen_string_literal: true

require "fileutils"
require_relative "libs/version"

module Saxon
  module Libs
    class Error < StandardError; end
    class UnknownEdition < Error; end
    class UnsupportedPlatform < Error; end

    class << self
      def saxonc_home
        release.saxonc_home
      end

      def release=(release)
        @release = release
      end
      
      def release
        @release
      end

      def edition
        release.edition
      end

      def version
        release.version
      end

      def ensure_installed!
        release.ensure_installed!
      end
    end
  end
end

require_relative "libs/release"
