# frozen_string_literal: true

require "fileutils"
require "json"
require "time"
require "zip"

require_relative "platform"
require_relative "releases"
require_relative "download"

module SaxonC
  module Libs
    # Coordinates download and extraction of the SaxonC distribution release.
    class Installer
      attr_reader :target_dir, :platform, :release, :edition

      def self.default_installation_dir
        File.expand_path("../../vendor/saxonc", __dir__)
      end

      def initialize(target: self.class.default_installation_dir, platform: Platform.detect, edition: :he)
        @target_dir = File.expand_path(target)
        @platform = platform
        @edition = edition.to_sym
        @release = Releases.new(@edition)
      end

      def install(force: false)
        return platform_dir if installed? && !force

        FileUtils.mkdir_p(File.dirname(platform_dir))
        release = release.release_for(platform.key)
        url = release.fetch("url")
        checksum = release["sha256"]

        puts "Downloading #{url}..."
        release_path = Download.new(url, checksum: checksum).fetch
        puts "Extracting to #{platform_dir}..."
        extract_release(release_path)
        File.delete(release_path) if File.exist?(release_path)
        write_release(release)
        puts "SaxonC runtime ready in #{platform_dir}"
        platform_dir
      end

      def installed?
        Dir.exist?(File.join(platform_dir, "lib")) && File.exist?(File.join(platform_dir, "release.json"))
      end

      def platform_dir
        File.join(target_dir, edition.to_s, platform.key)
      end

      private

      def extract_release(release_path)
        FileUtils.rm_rf(platform_dir)
        FileUtils.mkdir_p(platform_dir)

        Zip::File.open(release_path) do |zip_file|
          zip_file.each do |entry|
            next unless entry.file?

            relative_path = case entry.name
                            when /^SaxonCHE\//
                              entry.name.sub(/^SaxonCHE\//, "")
                            when /^notices\//
                              entry.name
                            when /^README/i
                              entry.name
                            else
                              next
                            end

            next if relative_path.empty?

            destination = File.join(platform_dir, relative_path)
            FileUtils.mkdir_p(File.dirname(destination))
            entry.extract(destination) { true }
          end
        end
      end

      def write_release(release)
        release_data = {
          platform: platform.key,
          saxon_version: SaxonC::Libs::SAXON_VERSION,
          edition: edition.to_s,
          release_url: release.fetch("url"),
          extracted_at: Time.now.utc.iso8601
        }

        File.write(File.join(platform_dir, "release.json"), JSON.pretty_generate(release_data))
      end
    end
  end
end
