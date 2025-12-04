# frozen_string_literal: true

require_relative "libs/version"
require_relative "libs/installer"
require_relative "libs/cli"

module SaxonC
  # Top-level namespace for the runtime helper gem.
  module Libs
    class << self
      def install(**options)
        Installer.new(**options).install
      end

      def ensure_installed(**options)
        install(**options)
      end

      def find_installation(edition: :he, target: Installer.default_installation_dir, platform: nil)
        resolved_platform = platform || SaxonC::Libs::Platform.detect
        installer = Installer.new(target: target, edition: edition, platform: resolved_platform)
        installer.platform_dir if installer.installed?
      end

      def default_installation_dir
        Installer.default_installation_dir
      end
    end
  end
end
