# frozen_string_literal: true

require "fileutils"
require "rbconfig"
require "tempfile"
require "open-uri"
require "zip"

module Saxon
  module Libs
    class Release
      attr_reader :edition, :version, :platform, :base_dir

      VERSION_REGEX = /\A(\d+)\.(\d+)\.(\d+)\z/
      def initialize(edition, version: Saxon::Libs::VERSION, base_dir: File.join(Dir.home, ".saxonc"))
        @edition = normalize_edition(edition)
        @version = version
        @base_dir = base_dir
      end

      def saxonc_home
        File.join(path, "SaxonC#{edition_upcase}")
      end

      def installed?
        File.exist?(path)
      end

      def ensure_installed!
        install! unless installed?
      end

      def platform
        current = "#{os}-#{arch}"
        
        unless available_platforms.include?(current)
          raise UnsupportedPlatform, "Unsupported platform: #{current || 'unknown'}"
        end

        current
      end
      
      private

      def path
        File.expand_path(File.join(base_dir, version, edition_upcase, platform))
      end


      def download_url
        "https://downloads.saxonica.com/SaxonC/#{edition_upcase}/#{version_major}/#{archive_prefix}-#{platform}-#{version_major}-#{version_minor}-#{version_patch}.zip"
      end

      def install!
        STDERR.puts "SaxonC does not appear to be installed in #{path}, installing!"
        FileUtils.mkdir_p(base_dir)

        Dir.mktmpdir("saxonc") do |temp_dir|
          zip_path = File.join(temp_dir, "saxonc.zip")

          begin
            STDERR.puts "Downloading SaxonC from #{download_url}..."
            URI.open(download_url) do |saxon_archive|
              File.binwrite(zip_path, saxon_archive.read)
            end
          rescue OpenURI::HTTPError => e
            raise "Failed to download SaxonC from #{download_url}, perhaps the version or platform is not supported: #{e.message}"
          rescue StandardError => e
            raise "An error occurred while downloading SaxonC: #{e.message}"
          end

          STDERR.puts "Extracting SaxonC..."
          Zip::File.open(zip_path) do |zip|
            zip.each do |entry|
              dest = File.join(temp_dir, entry.name)
              FileUtils.mkdir_p(File.dirname(dest))
              entry.extract(dest) { true }
            end
          end

          extracted_dir = Dir.glob(File.join(temp_dir, "*")).find { |p| File.directory?(p) }
          raise "Failed to extract SaxonC archive" unless extracted_dir

          FileUtils.mkdir_p(File.dirname(path))
          FileUtils.rm_rf(path)
          FileUtils.mv(extracted_dir, path)
          STDOUT.puts "\nSuccessfully installed SaxonC to #{path}!\n"
        ensure
          FileUtils.rm_rf(temp_dir) if defined?(temp_dir) && temp_dir && Dir.exist?(temp_dir)
        end

        raise "Failed to install SaxonC. Sorry :(" unless File.exist?(path)
      end

      def normalize_edition(value)
        value.to_s.downcase.to_sym
      end

      def edition_upcase
        edition.to_s.upcase
      end

      def version_major
        version.split(".")[0]
      end

      def version_minor
        version.split(".")[1]
      end

      def version_patch
        version.split(".")[2]
      end

      def archive_prefix
        case edition_upcase
        when "HE" then "SaxonCHE"
        when "PE" then "SaxonCPE"
        when "EE" then "SaxonCEE"
        else "SaxonC"
        end
      end

      def available_platforms
        [
          "linux-x86_64",
          "linux-aarch64",
          "macos-x86_64",
          "macos-arm64",
          "windows-x86_64"
        ]
      end

      def os
        case RbConfig::CONFIG["host_os"]
        when /linux/
          "linux"
        when /darwin/
          "macos"
        when /mswin|mingw|cygwin/
          "windows"
        else
          nil
        end
      end

      def arch
        RbConfig::CONFIG["host_cpu"]
      end
    end
  end
end
