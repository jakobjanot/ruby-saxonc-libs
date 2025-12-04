# frozen_string_literal: true

require "rbconfig"

module SaxonC
  module Libs
    # Detects and normalizes the current runtime platform.
    class Platform
      PLATFORM_MAP = {
        "macos-arm64" => ->(os, cpu) { os =~ /darwin/ && cpu =~ /arm|aarch64/ },
        "macos-x86_64" => ->(os, cpu) { os =~ /darwin/ && cpu =~ /x86_64|amd64/ },
        "linux-x86_64" => ->(os, cpu) { os =~ /linux/ && cpu =~ /x86_64|amd64/ },
        "windows-x86_64" => ->(os, cpu) { os =~ /mswin|mingw|cygwin/ && cpu =~ /x86_64|amd64/ }
      }.freeze

      attr_reader :key

      def self.detect
        host_os = RbConfig::CONFIG["host_os"].downcase
        host_cpu = RbConfig::CONFIG["host_cpu"].downcase

        key = PLATFORM_MAP.find { |_name, predicate| predicate.call(host_os, host_cpu) }&.first
        raise "Unsupported SaxonC platform for #{host_os}/#{host_cpu}" unless key

        new(key)
      end

      def initialize(key)
        @key = key
      end

      def to_s
        key
      end
    end
  end
end
